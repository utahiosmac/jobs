//
//  Dispatch.swift
//  Jobs
//

import Foundation

extension DispatchQueue {
    
    internal func after(timeInterval: TimeInterval, execute: () -> Void) {
        let when = DispatchTime.now() + DispatchTimeInterval.nanoseconds(Int(UInt64(timeInterval) * NSEC_PER_SEC))
        after(when: when, execute: execute)
    }
    
}
