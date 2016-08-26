//
//  Dispatch.swift
//  Jobs
//

import Foundation

extension DispatchQueue {
    
    internal func after(timeInterval: TimeInterval, execute: @escaping () -> Void) {
        let when = DispatchTime.now() + timeInterval
        asyncAfter(deadline: when, execute: execute)
    }
    
}
