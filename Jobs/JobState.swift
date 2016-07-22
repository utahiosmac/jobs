//
//  JobState.swift
//  Jobs
//

import Foundation

internal final class JobState {
    internal let enqueuedDate = Date()
    internal let job: JobType
    
    private enum State {
        case idle
        case evaluating
        case executing
        case finished([NSError])
        
        var isFinished: Bool {
            if case .finished(_) = self { return true }
            return false
        }
    }
    
    private let lock = Lock()
    
    // underscored properties must only be accessed within the lock
    private var _state = State.idle
    private var _cancelled = false
    private var _observers = [Observer]()
    
    internal var jobProductionHandler: (JobType) -> Ticket
    internal private(set) var cancellationError: NSError?
    
    init(job: JobType, productionHandler: (JobType) -> Ticket) {
        self.job = job
        self.jobProductionHandler = productionHandler
        add(observers: job.observers)
    }
    
    internal var isCancelled: Bool { return lock.withCriticalScope { _cancelled } }
    
    internal func add(observer: Observer) {
        add(observers: [observer])
    }
    
    internal func ticket() -> Ticket {
        return Ticket(state: self)
    }
    
}

extension JobState { /* Actions */
    
    internal func evaluateConditions(completion: ([NSError]) -> Void) {
        let shouldEvaluate = lock.withCriticalScope { _ -> Bool in
            if _state == .idle {
                _state = .evaluating
                return true
            }
            return false
        }
        
        guard shouldEvaluate == true else {
            fatalError("Attempting to evaluate conditions on a non-idle JobState")
        }
        
        let group = DispatchGroup()
        var results = Array<NSError?>(repeating: nil, count: job.conditions.count)
        
        let q = DispatchQueue(label: "JobConditions", attributes: .serial, target: nil)
        let ticket = self.ticket()
        for (index, condition) in job.conditions.enumerated() {
            group.enter()
            condition.evaluate(ticket: ticket) { error in
                q.async {
                    results[index] = error
                    group.leave()
                }
            }
        }
        
        group.notify(queue: q) {
            var errors = results.flatMap { $0 }
            
            if self.isCancelled {
                let error: NSError
                if let cancellationError = self.cancellationError {
                    error = cancellationError
                } else {
                    error = NSError(jobError: .cancelled)
                }
                // make the cancellation error first, because it must have been done manually
                // and manually-done things are more important
                errors.insert(error, at: 0)
            }
            completion(errors)
            
            if errors.isEmpty == false {
                self.finish(errors: errors)
            }
        }
    }
    
    internal func execute() {
        let handlers = lock.withCriticalScope { _ -> [Observer]? in
            if _state == .evaluating && _cancelled == false {
                _state = .executing
                return _observers
            } else {
                return nil
            }
        }
        
        if let handlers = handlers {
            let t = ticket()
            handlers.forEach { $0.jobDidStart(job: t) }
            let c = JobContext(state: self)
            job.block(c)
        }
    }
    
    internal func finish(errors: [NSError] = []) {
        let handlers = lock.withCriticalScope { _ -> [Observer] in
            if _state == .executing {
                _state = .finished(errors)
                let returnValue = _observers
                _observers = []
                return returnValue
            }
            return []
        }
        
        let t = ticket()
        handlers.forEach { $0.job(job: t, didFinishWithErrors: errors) }
    }
    
    internal func cancel(error: NSError? = nil) {
        let handlers = lock.withCriticalScope { _ -> [Observer] in
            // we can only cancel the job if it's not finished
            if _cancelled == false && _state.isFinished == false {
                _cancelled = true
                cancellationError = error
                return _observers
            }
            return []
        }
        
        let t = ticket()
        handlers.forEach { $0.jobDidCancel(job: t) }
    }
    
    internal func produce(job: JobType) -> Ticket {
        let newTicket = jobProductionHandler(job)
        let handlers = lock.withCriticalScope { _observers }
        
        let t = ticket()
        handlers.forEach { $0.job(job: t, didProduce: newTicket) }
        return newTicket
    }
    
}

extension JobState { /* Observation */
    
    func add(observers: [Observer]) {
        var actions = [() -> Void]()
        
        let t = ticket()
        lock.withCriticalScope {
            // we won't add observers to a job that has finished
            if _state.isFinished == false {
                _observers.append(contentsOf: observers)
            }
            
            if _cancelled == true && _state.isFinished == false {
                // we may need to notify of cancellation
                actions.append({
                    observers.forEach { $0.jobDidCancel(job: t) }
                })
            } else if case .finished(let errors) = _state {
                // we may need to notify of finishing
                actions.append({
                    observers.forEach { $0.job(job: t, didFinishWithErrors: errors) }
                })
            }
        }
        
        actions.forEach { $0() }
    }
    
}

private func ==(lhs: JobState.State, rhs: JobState.State) -> Bool {
    switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.evaluating, .evaluating): return true
        case (.executing, .executing): return true
        case (.finished(let lErrors), .finished(let rErrors)): return lErrors == rErrors
        default: return false
    }
}
