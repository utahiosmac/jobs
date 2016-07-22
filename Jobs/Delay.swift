//
//  Delay.swift
//  Jobs
//

import Foundation

public func Delay(interval: TimeInterval) -> JobType {
    var block = BlockJob(block: { context in
        var c = context
        let q = DispatchQueue.global()
        q.after(timeInterval: interval) {
            c.finish()
        }
        c.onCancel { c.finish() }
    })
    block.name = "Delay(\(interval))"
    return block
}
