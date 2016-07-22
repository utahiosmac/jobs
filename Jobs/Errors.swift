//
//  Errors.swift
//  Jobs
//

import Foundation

public let JobErrorDomain = "JobErrorDomain"

public enum JobError: Int {
    case cancelled
    case timedOut
    
    public var localizedDescription: String {
        switch self {
            case .cancelled: return "The job was cancelled"
            case .timedOut: return "The job timed out"
        }
    }
}

extension NSError {
    
    public convenience init(jobError: JobError, description: String? = nil, extra: Dictionary<NSObject, AnyObject> = [:]) {
        var info = extra
        info[NSLocalizedDescriptionKey] = description ?? jobError.localizedDescription
        
        self.init(domain: JobErrorDomain, code: jobError.rawValue, userInfo: info)
    }
    
}
