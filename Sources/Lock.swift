//
//  Lock.swift
//  Jobs
//

import Foundation

internal extension NSLocking {
    
    func withCriticalScope<T>(block: () -> T) -> T {
        lock()
        let value = block()
        unlock()
        return value
    }
    
}
