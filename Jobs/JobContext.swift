//
//  JobContext.swift
//  Jobs
//

import Foundation

public struct JobContext: Observable {
    private let state: JobState
    
    internal init(state: JobState) {
        self.state = state
    }
    
    public var isCancelled: Bool { return state.isCancelled }
    
    public func add(observer: Observer) {
        state.add(observer: observer)
    }
    
    public func cancel(error: NSError? = nil) {
        state.cancel(error: error)
    }
    
    public func finish(errors: [NSError] = []) {
        state.finish(errors: errors)
    }
    
    public func produce(job: JobType) -> Ticket {
        return state.produce(job: job)
    }
}
