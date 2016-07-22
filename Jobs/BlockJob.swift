//
//  BlockJob.swift
//  Jobs
//

import Foundation

public struct BlockJob: JobType {
    public var priority = DispatchQoS.default
    public let block: JobBlock
    public var name: String? = nil
    public private(set) var conditions = [Condition]()
    public private(set) var observers = [Observer]()
    
    public mutating func add(condition: Condition) {
        conditions.append(condition)
    }
    public mutating func add(observer: Observer) {
        observers.append(observer)
    }
    
    public init(block: JobBlock) {
        self.block = block
    }
    
    public init(mainQueueBlock: () -> Void) {
        self.block = { context in
            DispatchQueue.main.async {
                mainQueueBlock()
                context.finish()
            }
        }
    }
    
    public init() {
        self.block = { context in
            context.finish()
        }
    }
}
