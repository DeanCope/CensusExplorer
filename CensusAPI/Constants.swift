//
//  Constants.swift
//  CensusAPI
//
//  Created by Dean Copeland on 2/14/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import Foundation

// MARK: Errors
public enum CensusError: Error {
    case connectionFailed(method: String, errorString: String)
    case noStatusCode(method: String)
    case badStatusCode(code: String, url: String)
    case noDataReturned
    case parseFailed(detail: String)
    case dataError(detail: String)
    case otherError(reason: String)
    
    var description: String {
        switch self {
        case .connectionFailed(let method, let errorString): return "Connection failed for \(method): \(errorString)"
        case .noStatusCode(let method): return "No status code received for \(method)"
        case .badStatusCode(let code): return "Bad status code received: \(code)"
        case .noDataReturned: return "No data returned"
        case .parseFailed(let detail): return "Parse failed: \(detail)"
        case .dataError(let detail): return "Data Error: \(detail)"
        case .otherError(let reason): return "Error: \(reason)"
        }
    }
}

public enum Axis {
    case x
    case y
}

public enum ChartType {
    case line
    case scatter
}

