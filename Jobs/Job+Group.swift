//
//  Job+Group.swift
//  Jobs
//

import Foundation

public extension Job {
    
    public static func group(setup: (JobQueueType) -> Void) -> Job {
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
    
    private func enqueue(job: JobType) -> Ticket {
        let ticket = wrappedQueue.enqueue(job: job)
        ticket.add(observer: GroupJobObserver(group: group))
        return ticket
    }
    
    private func onCompletion(completion: () -> Void) {
        group.notify(queue: DispatchQueue.global(), execute: completion)
    }
    
}

private struct GroupJobObserver: Observer {
    private let group: DispatchGroup
    
    init(group: DispatchGroup) {
        self.group = group
        group.enter()
    }
    
    private func jobDidStart(job: Ticket) { }
    private func jobDidCancel(job: Ticket) { }
    private func job(job: Ticket, didFinishWithErrors errors: [NSError]) {
        group.leave()
    }
    private func job(job: Ticket, didProduce newJob: Ticket) {
        newJob.add(observer: GroupJobObserver(group: group))
    }
}
