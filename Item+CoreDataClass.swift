//
//  Item+CoreDataClass.swift
//  Bite
//
//  Created by Jamie Nguyen on 3/13/18.
//  Copyright © 2018 Jamie Nguyen. All rights reserved.
//
//

import Foundation
import CoreData


public class Item: NSManagedObject {
    convenience init(itemName: String, brandName: String?, calories: Int?, image_url: String?, serving_quantity: String?, serving_unit: String?, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Item", in: context) {
            self.init(entity: ent, insertInto: context)
            self.name = itemName
            self.brand_name = brandName
            if calories != nil {
                let c = NSNumber(value: calories!)
                self.calories = Int32(truncating: c)
            }
            self.image_url = image_url
            self.serving_unit = serving_unit
            self.serving_quantity = serving_quantity
        } else {
            fatalError("Unable to find Entity name")
        }
    }
    
    func downloadImage(imagePath:String, completionHandler: @escaping (_ imageData: Data?, _ errorString: String?) -> Void) -> URLSessionDataTask {
        let session = URLSession.shared
        let imgURL = NSURL(string: imagePath)
        let request: NSURLRequest = NSURLRequest(url: imgURL! as URL)
        
        let task = session.dataTask(with: request as URLRequest) {data, response, downloadError in
            if data == nil {
                completionHandler(nil, "Could not download image \(imagePath)")
            } else {
                completionHandler(data, nil)
            }
        }
        
        task.resume()
        return task
    }
}
