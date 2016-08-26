//
//  Dependency.swift
//  Jobs
//

import Foundation

public final class Depend: Condition {
    private var dependency: Ticket
    
    public init(on job: Ticket) {
        self.dependency = job
    }
    
    public func evaluate(ticket: Ticket, completion: @escaping (NSError?) -> Void) {
        dependency.onFinish { _ in
            completion(nil)
        }
    }
    
}

public extension JobType {
    
    mutating func depend(on job: Ticket) {
        add(condition: Depend(on: job))
    }
    
}
