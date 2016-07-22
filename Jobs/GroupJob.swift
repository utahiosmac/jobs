//
//  GroupJob.swift
//  Jobs
//

import Foundation

public struct GroupJob: JobType {
    public var priority = DispatchQoS.default
    public var name: String? = nil
    public let block: JobBlock
    public private(set) var conditions = [Condition]()
    public private(set) var observers = [Observer]()
    
    mutating public func add(condition: Condition) {
        conditions.append(condition)
    }
    mutating public func add(observer: Observer) {
        observers.append(observer)
    }
    
    public init(setup: (JobQueueType) -> Void) {
        self.block = { context in
            let q = GroupJobQueue()
            q.suspended = true
            setup(q)
            q.onCompletion {
                context.finish()
            }
            q.suspended = false
        }
    }
}

private class GroupJobQueue: JobQueueType {
    
    private let wrappedQueue = JobQueue()
    private let group = DispatchGroup()
    
    var suspended: Bool {
        get { return wrappedQueue.suspended }
        set { wrappedQueue.suspended = newValue }
    }
    
    private func enqueue(job: JobType) -> Ticket {
        let g = group
        g.enter()
        var ticket = wrappedQueue.enqueue(job: job)
        ticket.onFinish { _ in g.leave() }
        return ticket
    }
    
    private func onCompletion(completion: () -> Void) {
        group.notify(queue: DispatchQueue.global(), execute: completion)
    }
    
}
