//
//  CensusClient.swift
//  CensusAPI
//
//  Created by Dean Copeland on 6/14/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import Foundation
import UIKit

// MARK: - CensusClient: NSObject

class CensusClient : NSObject {
    
    // MARK: Properties
    
    // shared session
    var session = URLSession.shared
    
    var methods = [
        Sources.SAIPE: "timeseries/poverty/saipe",
        Sources.ACS: "2015/acs1/cprofile"
    ]
    
    //  source: http://www.djbp.co.uk/swift-development-managing-the-network-activity-indicator/
    var activityIndicatorSetVisibleCount = 0
    func setNetworkActivityIndicatorVisible(visible: Bool) {
        if visible {
            activityIndicatorSetVisibleCount += 1
        }else {
            activityIndicatorSetVisibleCount -= 1
        }
        
        // If you have more closes than opens, make sure not to enter into minus numbers
        if activityIndicatorSetVisibleCount < 0 {
            activityIndicatorSetVisibleCount = 0
        }
        print("\(activityIndicatorSetVisibleCount) network requests are in progress.")
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = self.activityIndicatorSetVisibleCount > 0
        }
    }
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    
    // MARK: GET
    
    func taskForGETMethod(_ method: String, parameters: [String:AnyObject], completionHandlerForGET: @escaping (_ result: [AnyObject]?, _ error: CensusClientError?) -> Void) -> URLSessionDataTask {
        
        /* 1. Set the parameters */
        var parametersWithApiKey = parameters
        parametersWithApiKey[ParameterKeys.APIKey] = ParameterValues.APIKey as AnyObject?
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(url: censusURLFromParameters(parametersWithApiKey, withPathExtension: method))
        
        request.addValue(HeaderValues.Json, forHTTPHeaderField: HeaderKeys.Accept)
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            self.setNetworkActivityIndicatorVisible(visible: false)
            
            func sendError(_ error: CensusClientError) {
                completionHandlerForGET(nil, error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError(.connectionFailed(method: "GET", errorString: error!.localizedDescription))
                return
            }
            
            /* GUARD: Did we get a status code? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                sendError(.noStatusCode(method: "GET"))
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard statusCode >= 200 && statusCode <= 299 else {
                sendError(.badStatusCode(code: String(statusCode), url: String(describing: request.url)))
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError(.noDataReturned)
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        /* 7. Start the request */
        setNetworkActivityIndicatorVisible(visible: true)
        task.resume()
        
        return task
    }
    
    
    // MARK: Helpers
        
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: [AnyObject]?, _ error: CensusClientError?) -> Void) {
        
        //   print("Json Data:")
        //   print(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)
        
        var parsedResult: [AnyObject]?
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [AnyObject]
        } catch let error {
            completionHandlerForConvertData(nil, .parseFailed(detail: error.localizedDescription))
        }
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    // create a Census URL from parameters
    private func censusURLFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = Constants.ApiPath + "/" + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> CensusClient {
        struct Singleton {
            static var sharedInstance = CensusClient()
        }
        return Singleton.sharedInstance
    }
}
