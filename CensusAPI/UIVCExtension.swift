//
//  DisplayAlert.swift
//  OnTheMap
//
//  Created by Dean Copeland on 4/27/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

//import Foundation
import UIKit

extension UIViewController {
    
    func alert(title: String = "Error", message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func startObserving(notificationName: String, _ closure: @escaping (_ notification: NSNotification) -> Void) -> Any? {
        let center = NotificationCenter.default
        let observer = center.addObserver(forName: NSNotification.Name(rawValue: notificationName), object: nil, queue: OperationQueue.main) {
            notification in
            closure(notification as NSNotification)
        }
        return observer
    }
    
    func stopObservingNotification(observer: Any?) {
        if let _ = observer {
            let center = NotificationCenter.default
            center.removeObserver(observer!)
        }
    }
 
    func startObservingGetGeographiesErrorNotification() -> Any? {
  
        let observer = startObserving(notificationName: NotificationNames.GetGeographiesError) { notification in
            var message = "Error getting geographies data"
            if let userInfo = notification.userInfo {
                if let error = userInfo[NotificationNames.CensusClientError] as? CensusClient.CensusClientError {
                    message = "\(message): \(error.localizedDescription)"
                }
            }
            self.alert(message: message)
        }
        return observer
    }
    
    func startObservingGetCensusValuesErrorNotification() -> Any? {
        
        let observer = startObserving(notificationName: NotificationNames.GetCensusValuesError) { notification in
            var message = "Error getting census values data"
            if let userInfo = notification.userInfo {
                if let error = userInfo[NotificationNames.CensusClientError] as? CensusClient.CensusClientError {
                    message = "\(message): \(error.localizedDescription)"
                }
            }
            self.alert(message: message)
        }
        return observer
    }
    
    func startObservingGotCensusValuesNotification() -> Any? {
        
        let observer = startObserving(notificationName: NotificationNames.GotCensusValues) { notification in
            self.alert(title: "Done", message: "Census data has been reloaded.")
        }
        return observer
    }
 
}

