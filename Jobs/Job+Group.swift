//
//  Job+Group.swift
//  Jobs
//

import Foundation

public extension Job {
    
    public static func group(setup: @escaping (JobQueueType) -> Void) -> Job {
        return Job(block: { context in
            let q = GroupJobQueue()
            q.suspended = true
            setup(q)
            q.onCompletion {
                context.finish()
            }
            q.suspended = false
        })
    }
    
}

private class GroupJobQueue: JobQueueType {
    
    private let wrappedQueue = JobQueue()
    private let group = DispatchGroup()
    
    var suspended: Bool {
        get { return wrappedQueue.suspended }
        set { wrappedQueue.suspended = newValue }
    }
    
    fileprivate func enqueue(job: JobType) -> Ticket {
        let ticket = wrappedQueue.enqueue(job: job)
        ticket.add(observer: GroupJobObserver(group: group))
        return ticket
    }
    
    fileprivate func onCompletion(completion: @escaping () -> Void) {
        group.notify(queue: DispatchQueue.global(), execute: completion)
    }
    
}

private struct GroupJobObserver: Observer {
    private let group: DispatchGroup
    
    init(group: DispatchGroup) {
        self.group = group
        group.enter()
    }
    
    fileprivate func jobDidStart(job: Ticket) { }
    fileprivate func jobDidCancel(job: Ticket) { }
    fileprivate func job(job: Ticket, didFinishWithErrors errors: [NSError]) {
        group.leave()
    }
    fileprivate func job(job: Ticket, didProduce newJob: Ticket) {
        newJob.add(observer: GroupJobObserver(group: group))
    }
}
