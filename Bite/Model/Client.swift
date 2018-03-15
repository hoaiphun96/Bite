//
//  SearchFood.swift
//  Bite
//
//  Created by Jamie Nguyen on 2/23/18.
//  Copyright © 2018 Jamie Nguyen. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Client {
    
    static let sharedInstance = Client()

    // MARK: Make Network Request
    
    func getFoodFromNutritionix(item: String, completionHandlerForGetFood: @escaping (_ result: [Constants.TempItem]?,_ errorString: String?) -> Void) -> URLSessionDataTask {
        // [creating the url and request]...
        let methodParameters = ["query" : item] as [String : Any]
        let method = "search/instant"
        
        let urlString = Constants.Nutritionix.APIBaseURL + method + escapedParameters(methodParameters as [String:AnyObject])
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.addValue(Constants.NutritionixParameterValues.ApplicationID, forHTTPHeaderField: "x-app-id")
        request.addValue(Constants.NutritionixParameterValues.APIKey, forHTTPHeaderField: "x-app-key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // create network request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            guard error == nil else {
                completionHandlerForGetFood(nil, "URL at time of error: \(url)")
                return
            }
            
            // there was data returned
            if let data = data {
                let parsedResult: [String:AnyObject]!
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                } catch {
                    completionHandlerForGetFood(nil, "Could not parse the data as JSON: '\(data)'")
                    return
                }
                var tempItems = [Constants.TempItem]()
                if let brandedDictionary = parsedResult["branded"] as? [[String:AnyObject]] {
                    let brandedItems = Constants.TempItem.itemsFromResults(brandedDictionary)
                    tempItems = tempItems + brandedItems
                   
                } else {
                    debugPrint("Cannot find key branded in dictionary")
                }
                if let commonDictionary = parsedResult["common"] as? [[String:AnyObject]] {
                    let commonItems = Constants.TempItem.itemsFromResults(commonDictionary)
                    //completionHandlerForGetFood(tempItems, nil)
                    tempItems = tempItems + commonItems
                }
                else {
                    debugPrint("Cannot find key common in dictionary")
                }
                if tempItems.count == 0 {
                    completionHandlerForGetFood(nil, "Cannot find any food")
                } else {
                    completionHandlerForGetFood(tempItems, nil)
                }
            }
        }
        // start the task!
        task.resume()
        return task
    }
    
    private func escapedParameters(_ parameters: [String:AnyObject]) -> String {
        
        if parameters.isEmpty {
            return ""
        } else {
            var keyValuePairs = [String]()
            
            for (key, value) in parameters {
                
                // make sure that it is a string value
                let stringValue = "\(value)"
                
                // escape it
                let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                
                // append it
                keyValuePairs.append(key + "=" + "\(escapedValue!)")
                
            }
            
            return "?\(keyValuePairs.joined(separator: "&"))"
        }
    }
    
    // MARK: SHOW ALERT MESSAGE
    func showAlertMessage(title: String, message: String, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: "Default action"), style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
}

import SystemConfiguration
extension Client {
    // check for network connection
    // Credit to https://stackoverflow.com/questions/25623272/how-to-use-scnetworkreachability-in-swift
    func isInternetAvailable() -> Bool {
        guard let flags = getFlags() else { return false }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        debugPrint(isReachable, needsConnection, isReachable && !needsConnection)
        
        return (isReachable && !needsConnection)
    }
    
    func getFlags() -> SCNetworkReachabilityFlags? {
        guard let reachability = ipv4Reachability() ?? ipv6Reachability() else {
            return nil
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(reachability, &flags) {
            return nil
        }
        return flags
    }
    
    func ipv6Reachability() -> SCNetworkReachability? {
        var zeroAddress = sockaddr_in6()
        zeroAddress.sin6_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin6_family = sa_family_t(AF_INET6)
        
        return withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        })
    }
    
    func ipv4Reachability() -> SCNetworkReachability? {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        return withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        })
    }
}
