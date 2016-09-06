//
//  Composite.swift
//  Jobs
//

import Foundation

public struct Composite: Condition {
    public enum Requirement {
        case all
        case any
    }
    private let conditions: [Condition]
    private let requirement: Requirement
    
    public init(requirement: Requirement = .all, conditions: Condition ...) {
        self.requirement = requirement
        self.conditions = conditions
    }
    
    public func evaluate(ticket: Ticket, completion: @escaping (NSError?) -> Void) {
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "CompositeCondition", attributes: [], target: DispatchQueue.global())
        
        let conditionCount = conditions.count
        
        var results = Array<NSError?>(repeating: nil, count: conditionCount)
        for (index, condition) in conditions.enumerated() {
            group.enter()
            condition.evaluate(ticket: ticket) { error in
                results[index] = error
                group.leave()
            }
        }
        
        let r = requirement
        
        group.notify(queue: queue) {
            // called when all conditions have evaluated
            let errors = results.flatMap { $0 }
            switch r {
                case .all:
                    let error: NSError? = (errors.count == 0) ? nil : errors[0]
                    completion(error)
                case .any:
                    let error: NSError? = (errors.count < conditionCount) ? nil : errors[0]
                    completion(error)
            }
        }
    }
    
}
