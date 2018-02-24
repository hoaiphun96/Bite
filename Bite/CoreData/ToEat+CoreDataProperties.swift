//
//  ToEat+CoreDataProperties.swift
//  Bite
//
//  Created by Jamie Nguyen on 2/23/18.
//  Copyright © 2018 Jamie Nguyen. All rights reserved.
//
//

import Foundation
import CoreData


extension ToEat {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToEat> {
        return NSFetchRequest<ToEat>(entityName: "ToEat")
    }

    @NSManaged public var items: Item?

}
