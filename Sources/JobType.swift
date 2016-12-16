//
//  JobType.swift
//  Jobs
//

import Foundation

public typealias JobBlock = (JobContext) -> Void

public protocol JobType: Observable {
    var priority: DispatchQoS { get }
    var block: JobBlock { get }
    
    var conditions: [Condition] { get }
    var observers: [Observer] { get }
    
    var name: String? { get }
    
    mutating func add(condition: Condition)
}



