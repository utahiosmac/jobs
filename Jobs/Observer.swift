//
//  Observer.swift
//  Jobs
//

import Foundation

public protocol Observer {
    
    /// Invoked immediately prior to the Job's block executing
    func jobDidStart(job: Ticket)
    
    /// Invoked immediately after the first time the Job is cancelled
    func jobDidCancel(job: Ticket)
    
    /// Invoked when JobContext.produce(job:) is executed.
    func job(job: Ticket, didProduce newJob: Ticket)
    
    /**
     Invoked as a Job finishes, along with any errors produced during
     execution (or condition evaluation).
     */
    func job(job: Ticket, didFinishWithErrors errors: [NSError])
    
}

public protocol Observable {
    
    mutating func add(observer: Observer)
    
}

extension Observable {
    
    public mutating func onStart(handler: () -> Void) {
        add(observer: BlockObserver(onStart: handler))
    }
    
    public mutating func onCancel(handler: () -> Void) {
        add(observer: BlockObserver(onCancel: handler))
    }
    
    public mutating func onFinish(handler: ([NSError]) -> Void) {
        add(observer: BlockObserver(onFinish: handler))
    }
    
    public mutating func onProduce(handler: (Ticket) -> Void) {
        add(observer: BlockObserver(onProduce: handler))
    }
    
}
