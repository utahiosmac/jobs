//
//  MutuallyExclusive.swift
//  Jobs
//

import Foundation

public struct MutuallyExclusive<T>: Condition {
    
    public init() { }
    
    public func evaluate(ticket: Ticket, completion: @escaping (NSError?) -> Void) {
        let exclusivityClass = "\(type(of: self))"
        MutualExclusivityController.shared.add(ticket: ticket, for: exclusivityClass, completion: { completion(nil) })
    }
    
}

private class MutualExclusivityController {
    
    static let shared = MutualExclusivityController()
    
    private let lock = NSLock()
    private var tickets = Dictionary<String, [Ticket]>()
    
    func add(ticket: Ticket, for exclusivityClass: String, completion: @escaping () -> Void) {
        var mutableTicket = ticket
        var previousTicket: Ticket?
        lock.withCriticalScope {
            var ticketsForThisClass = tickets[exclusivityClass] ?? []
            previousTicket = ticketsForThisClass.last
            ticketsForThisClass.append(ticket)
            tickets[exclusivityClass] = ticketsForThisClass
        }
        
        mutableTicket.onFinish { _ in
            // clean up
            self.cleanUp(ticket: ticket, for: exclusivityClass)
        }
        
        if var previous = previousTicket {
            previous.onFinish { _ in completion() }
        } else {
            completion()
        }
    }
    
    private func cleanUp(ticket: Ticket, for exclusivityClass: String) {
        lock.withCriticalScope {
            if let ticketsForThisClass = tickets[exclusivityClass] {
                let filtered = ticketsForThisClass.filter { $0 != ticket }
                tickets[exclusivityClass] = filtered
            }
        }
    }
    
}
