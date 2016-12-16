//
//  BlockObserver.swift
//  Jobs
//

import Foundation

public struct BlockObserver: Observer {
    internal let onStart: (() -> Void)?
    internal let onCancel: (() -> Void)?
    internal let onFinish: (([NSError]) -> Void)?
    internal let onProduce: ((Ticket) -> Void)?
    
    public init(onStart: (() -> Void)? = nil, onCancel: (() -> Void)? = nil, onFinish: (([NSError]) -> Void)? = nil, onProduce: ((Ticket) -> Void)? = nil) {
        self.onStart = onStart
        self.onCancel = onCancel
        self.onFinish = onFinish
        self.onProduce = onProduce
    }
    
    public func jobDidStart(job: Ticket) {
        onStart?()
    }
    
    public func jobDidCancel(job: Ticket) {
        onCancel?()
    }
    
    public func job(job: Ticket, didFinishWithErrors errors: [NSError]) {
        onFinish?(errors)
    }
    
    public func job(job: Ticket, didProduce newJob: Ticket) {
        onProduce?(job)
    }
}
