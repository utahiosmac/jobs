//
//  Lock.swift
//  Jobs
//

import Foundation

internal extension Locking {
    
    func withCriticalScope<T>(block: @noescape () -> T) -> T {
        lock()
        let value = block()
        unlock()
        return value
    }
    
}
