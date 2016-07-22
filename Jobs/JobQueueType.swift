//
//  JobQueueType.swift
//  Jobs
//

import Foundation

public protocol JobQueueType {
    
    func enqueue(job: JobType) -> Ticket
    
}
