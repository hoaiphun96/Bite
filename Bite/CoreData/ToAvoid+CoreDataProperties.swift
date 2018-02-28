//
//  ToAvoid+CoreDataProperties.swift
//  Bite
//
//  Created by Jamie Nguyen on 2/28/18.
//  Copyright © 2018 Jamie Nguyen. All rights reserved.
//
//

import Foundation
import CoreData


extension ToAvoid {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToAvoid> {
        return NSFetchRequest<ToAvoid>(entityName: "ToAvoid")
    }

    @NSManaged public var items: NSSet?

}

// MARK: Generated accessors for items
extension ToAvoid {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: Item)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: Item)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}
