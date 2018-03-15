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
    var item: Client.Constants.TempItem!
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var toEat = false
    var toAvoid = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemInfoLabel.text = "Name: \(item.name) \nBrand: \(item.brand_name ?? "NA") \nServing Quantity: \(item.serving_quantity ?? "NA")\nServing unit: \(item.serving_unit ?? "NA") \nCalories: \(item.calories ?? 0)"
        
        // if item is already in core data, get value of toEat and toAvoid from core data
        let checkObject = isObjectInContext(item: self.item)
        if checkObject.0 {
            toAvoid = checkObject.1![0].toAvoid
            toEat = checkObject.1![0].toEat
        }
        configUI()
    }
    
    func configUI() {
        self.navigationController!.navigationBar.topItem!.title = ""
        itemImageView.image = item.image
        itemImageView.backgroundColor = UIColor.black
        itemImageView.layer.cornerRadius = itemImageView.frame.height / 2
        addToToAvoidButton.tintColor = UIColor(named: "DeepLight")
        addToToEatButton.tintColor = UIColor(named: "DeepLight")
        // set image for to eat and to avoid button if item has already been marked before
        if toEat {
            addToToEatButton.setImage(UIImage(named: "icons8-heart-outline-filled-50"), for: .normal)
        }
        if toAvoid {
            addToToAvoidButton.setImage(UIImage(named: "icons8-unavailable-filled-50"), for: .normal)
        }
    }
    @IBAction func addToToEat(_ sender: Any) {
        if toEat == false {
            self.addToToEatButton.setImage(UIImage(named: "icons8-heart-outline-filled-50"), for: .normal)
            self.addToToAvoidButton.setImage(UIImage(named: "icons8-unavailable-50"), for: .normal)
            self.toEat = true
            self.toAvoid = false
        } else {
            self.addToToEatButton.setImage(UIImage(named: "icon8-heart-50"), for: .normal)
            self.toEat = false
        }
        let checkObject = isObjectInContext(item: self.item)
        
        // if item is not in core data context, then create an item and save to core data
        if !checkObject.0 {
            let item = Item(itemName: self.item.name, brandName: self.item.brand_name, calories: self.item.calories, image_url: self.item.image_url, serving_quantity: self.item.serving_quantity, serving_unit: self.item.serving_unit, context: delegate.stack.context)
            item.toAvoid = toAvoid
            item.toEat = toEat
            delegate.stack.save()
        } else {
            // else change toAvoid and toEat attribute to current settings
            checkObject.1![0].toAvoid = toAvoid
            checkObject.1![0].toEat = toEat
            self.delegate.stack.save()
        }
    }
    
    @IBAction func addToToAvoid(_ sender: Any) {
        if toAvoid == false {
            self.addToToAvoidButton.setImage(UIImage(named: "icons8-unavailable-filled-50"), for: .normal)
            self.addToToEatButton.setImage(UIImage(named: "icon8-heart-50"), for: .normal)
            self.toAvoid = true
            self.toEat = false
        } else {
            self.addToToAvoidButton.setImage(UIImage(named: "icons8-unavailable-50"), for: .normal)
            self.toAvoid = false
        }
        let checkObject = isObjectInContext(item: self.item)
        
        // if item is not in core data context, then create an item and save to core data
        if !checkObject.0 {
        let item = Item(itemName: self.item.name, brandName: self.item.brand_name, calories: self.item.calories, image_url: self.item.image_url, serving_quantity: self.item.serving_quantity, serving_unit: self.item.serving_unit, context: delegate.stack.context)
            item.toAvoid = toAvoid
            item.toEat = toEat
            delegate.stack.save()
        } else {
        // else change toAvoid and toEat attribute to current settings
            checkObject.1![0].toAvoid = toAvoid
            checkObject.1![0].toEat = toEat
            self.delegate.stack.save()
        }
    }
    
    // check if item is in core data
    func isObjectInContext(item: Client.Constants.TempItem) -> (Bool, [Item]?) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        let namePredicate = NSPredicate(format: "name = %@", item.name)
        if let brand_name = item.brand_name {
            let brandNamePredicate = NSPredicate(format: "brand_name = %@", brand_name)
            let andPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [namePredicate, brandNamePredicate])
            fetchRequest.predicate = andPredicate
        } else {
            fetchRequest.predicate = namePredicate
        }
        do {
            let items = try delegate.stack.context.fetch(fetchRequest) as! [Item]
            if items.count > 0 {
                return (true, items)
            } else {
                return (false, nil)
            }
            
        } catch {
            debugPrint("There was an error fetching item from core data")
        }
        return (false, nil)
    }
    

}
