//
//  SearchFood.swift
//  Bite
//
//  Created by Jamie Nguyen on 2/23/18.
//  Copyright © 2018 Jamie Nguyen. All rights reserved.
//

import Foundation
import CoreData

public class SearchFood {
    
    static let sharedInstance = SearchFood()

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
        print("REQUEST", request)
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
                
                if let brandedDictionary = parsedResult["branded"] as? [[String:AnyObject]] {
                    let tempItems = Constants.TempItem.itemsFromResults(brandedDictionary)
                    completionHandlerForGetFood(tempItems, nil)
                   
                } else {
                    print("else")
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
    
}
