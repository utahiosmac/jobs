//
//  Timeout.swift
//  Jobs
//

import Foundation

public struct Timeout: Observer {
    private let interval: TimeInterval
    
    public init(after: TimeInterval) {
        interval = after
    }
    
    public func jobDidStart(job: Ticket) {
        // When the job starts, queue up a block to cause it to time out.
        DispatchQueue.global().after(timeInterval: interval) {
            // always cancel the job
            // if the job has already been cancelled or has already finished, this has no effect
            let error = NSError(jobError: .timedOut)
            job.cancel(error: error)
        }
    }
    
    public func jobDidCancel(job: Ticket) { }
    public func job(job: Ticket, didFinishWithErrors errors: [NSError]) { }
    public func job(job: Ticket, didProduce newJob: Ticket) { }
}
