//
//  Item+CoreDataProperties.swift
//  Bite
//
//  Created by Jamie Nguyen on 2/28/18.
//  Copyright © 2018 Jamie Nguyen. All rights reserved.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var brand_name: String?
    @NSManaged public var calories: Int32
    @NSManaged public var image_url: String?
    @NSManaged public var name: String?
    @NSManaged public var serving_quantity: String?
    @NSManaged public var serving_unit: String?
    @NSManaged public var toAvoid: Bool
    @NSManaged public var toEat: Bool
    @NSManaged public var image: NSData?
    @NSManaged public var avoid: ToAvoid?
    @NSManaged public var eat: ToEat?

}
