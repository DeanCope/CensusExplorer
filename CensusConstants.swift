//
//  CensusConstants.swift
//  CensusAPI
//
//  Created by Dean Copeland on 6/14/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

// MARK: - CensusClient (Constants)

extension CensusClient {
    
    public enum GeographyLevel {
        case nation
        case state
    }
    
    // MARK: Constants
    struct Constants {
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "api.census.gov"
        static let ApiPath = "/data"
    }
    
    struct Sources {
        static let SAIPE = "SIAPE"
        static let ACS = "ACS"
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        static let Get = "get"
        static let For = "for"
        static let Time = "time"
        static let APIKey = "key"
    }
    
    // MARK: Header Field Keys
    struct HeaderKeys {
        static let Accept = "Accept"
    }
    
    // MARK: Header Field Values
    struct HeaderValues {
        static let Json = "application/json"
    }

    static let Years = ["2012", "2013", "2014", "2015", "2016"]
    
    /*
    struct Variables {
                
        static let EdFactGroupName = "Education"
    }
 */
    static let GeoLevels = ["010":"Country","040": "State(s)"]
}
