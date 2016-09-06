//
//  Ticket.swift
//  Jobs
//

import Foundation

public struct Ticket: Hashable, Observable {
    public var enqueuedDate: Date { return state.enqueuedDate }
    public var job: JobType { return state.job }
    
    fileprivate let state: JobState
    
    internal init(state: JobState) {
        self.state = state
    }
    
    public var isCancelled: Bool { return state.isCancelled }
    
    public var hashValue: Int { return enqueuedDate.hashValue ^ isCancelled.hashValue }
    
    public func cancel(error: NSError? = nil) { state.cancel(error: error) }
    
    public func add(observer: Observer) { state.add(observer: observer) }
    
}

public func ==(lhs: Ticket, rhs: Ticket) -> Bool { return lhs.state === rhs.state }
