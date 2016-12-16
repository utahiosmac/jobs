//
//  JobQueue.swift
//  Jobs
//

import Foundation

public final class JobQueue: JobQueueType {
    public static let main: JobQueue = JobQueue(targeting: .main)
    
    private let executionQueue: DispatchQueue
    
    public init(targeting: DispatchQueue? = nil) {
        executionQueue = DispatchQueue(label: "JobQueue", attributes: [], target: targeting)
    }
    
    private var _suspended = false
    public var suspended: Bool {
        get { return _suspended }
        set {
            _suspended = newValue
            newValue ? executionQueue.suspend() : executionQueue.resume()
        }
    }
    
    public func enqueue(job: JobType) -> Ticket {
        let production = { (job: JobType) -> Ticket in
            return self.enqueue(job: job)
        }
        let state = JobState(job: job, productionHandler: production)
        state.evaluateConditions { errors in
            self.job(state, didEvaluateConditionsWithErrors: errors)
        }
        return state.ticket()
    }
    
    private func job(_ job: JobState, didEvaluateConditionsWithErrors errors: [NSError]) {
        guard errors.isEmpty == true else { return }
        
        // we should be using DispatchWorkItem here (so we can specify priority),
        // but DispatchWorkItem has a memory leak
        
        let block = { job.execute() }
//        let work = DispatchWorkItem(group: nil, qos: job.job.priority, flags: [], block: block)
        executionQueue.async(execute: block)
    }
    
}
