//
//  DetailViewController.swift
//  Bite
//
//  Created by Jamie Nguyen on 2/23/18.
//  Copyright © 2018 Jamie Nguyen. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {
    
    @IBOutlet weak var addToToAvoidButton: UIButton!
    @IBOutlet weak var addToToEatButton: UIButton!
    @IBOutlet weak var itemInfoLabel: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    var item: Constants.TempItem!
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.topItem!.title = ""
    }
    @IBAction func addToToEat(_ sender: Any) {
        let item = Item(itemName: self.item.name, brandName: self.item.brand_name, calories: self.item.calories, image_url: self.item.image_url, serving_quantity: self.item.serving_quantity, serving_unit: self.item.serving_unit, context: delegate.stack.context)
        item.toAvoid = false
        item.toEat = true
        print("just added to eat")
        delegate.stack.save()
        print("number of item in database \(delegate.stack.context.insertedObjects)")
    }
    
    @IBAction func addToToAvoid(_ sender: Any) {
        let item = Item(itemName: self.item.name, brandName: self.item.brand_name, calories: self.item.calories, image_url: self.item.image_url, serving_quantity: self.item.serving_quantity, serving_unit: self.item.serving_unit, context: delegate.stack.context)
        item.toAvoid = true
        item.toEat = false
        print("just added to avoid")
        delegate.stack.save()
    }


}
