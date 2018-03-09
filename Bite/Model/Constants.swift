//
//  Constants.swift
//  Bite
//
//  Created by Jamie Nguyen on 2/23/18.
//  Copyright © 2018 Jamie Nguyen. All rights reserved.
//
import UIKit
struct Constants {
    
    // MARK: Nutritionix
    struct Nutritionix {
        static let APIBaseURL = "https://trackapi.nutritionix.com/v2/"
    }
    
    // MARK: Nutritionix Parameter Keys
    struct NutritionixParameterKeys {
        static let ApplicationID = "method"
        static let APIKey = "api_key"
    }
    
    // MARK: Nutritionix Parameter Values
    struct NutritionixParameterValues {
        static let ApplicationID = "bc29c81f"
        static let APIKey = "fadec995b490ade258351633d5a90ba9"
        static let DisableJSONCallback = "1" /* 1 means "yes" */
        static let SearchInstantMethod = "search/instant"
   
    }
    
    // MARK: Nutritionix Response Keys
    struct NutritionixResponseKeys {
      
    }
    
    // MARK: Nutritionix Response Values
    struct NutritionixResponseValues {
        static let OKStatus = "ok"
    }
    
    struct TempItem {
        
        // MARK: Properties
        
        let name: String
        let brand_name: String?
        let calories: Int?
        let image_url: String?
        let serving_unit: String?
        let serving_quantity: String?
        var image: UIImage?
        
        // MARK: Initializers
        
        // construct a TempItem from a dictionary
        init(dictionary: [String:AnyObject]) {
            name = dictionary["food_name"] as! String
            brand_name = dictionary["brand_name"] as? String
            calories = dictionary["nf_calories"] as? Int
            let pd = dictionary["photo"] as! [String: AnyObject]
            image_url = pd["thumb"] as? String
            serving_unit = dictionary["serving_unit"] as? String
            serving_quantity = dictionary["serving_qty"] as? String
            image = nil
        }
        
      
        
        static func itemsFromResults(_ results: [[String:AnyObject]]) -> [TempItem] {
            var items = [TempItem]()
            
            // iterate through array of dictionaries, each Movie is a dictionary
            for result in results {
                items.append(TempItem(dictionary: result))
            }
            
            return items
        }
    }

}


