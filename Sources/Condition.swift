//
//  Condition.swift
//  Jobs
//

import Foundation

public protocol Condition {
    // passing nil to the completion means no error; the condition successfully evaluated
    func evaluate(ticket: Ticket, completion: @escaping (NSError?) -> Void)
}
