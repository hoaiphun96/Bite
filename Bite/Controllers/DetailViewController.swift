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
        configUI()
        itemInfoLabel.text = "Name: \(item.name) \nBrand: \(item.brand_name ?? "NA") \nServing Quantity: \(item.serving_quantity ?? "NA")\nServing unit: \(item.serving_unit ?? "NA") \nCalories: \(item.calories ?? 0)"
    }
    
    func configUI() {
        self.navigationController!.navigationBar.topItem!.title = ""
        itemImageView.image = item.image
        itemImageView.backgroundColor = UIColor.black
        itemImageView.layer.cornerRadius = itemImageView.frame.height / 2
        addToToAvoidButton.tintColor = UIColor(named: "DeepLight")
        addToToEatButton.tintColor = UIColor(named: "DeepLight")
    }
    @IBAction func addToToEat(_ sender: Any) {
        let checkObject = isObjectInContext(item: self.item)
        if !checkObject.0 {
        let item = Item(itemName: self.item.name, brandName: self.item.brand_name, calories: self.item.calories, image_url: self.item.image_url, serving_quantity: self.item.serving_quantity, serving_unit: self.item.serving_unit, context: delegate.stack.context)
        item.toAvoid = false
        item.toEat = true
        delegate.stack.save()
        } else {
            if checkObject.1![0].toAvoid == true {
                checkObject.1![0].toAvoid = false
                checkObject.1![0].toEat = true
                delegate.stack.save()
            }
        }
    }
    
    @IBAction func addToToAvoid(_ sender: Any) {
        let checkObject = isObjectInContext(item: self.item)
        if !checkObject.0 {
        let item = Item(itemName: self.item.name, brandName: self.item.brand_name, calories: self.item.calories, image_url: self.item.image_url, serving_quantity: self.item.serving_quantity, serving_unit: self.item.serving_unit, context: delegate.stack.context)
        item.toAvoid = true
        item.toEat = false
        delegate.stack.save()
        } else {
            if checkObject.1![0].toAvoid == false {
                checkObject.1![0].toAvoid = true
                checkObject.1![0].toEat = false
                self.delegate.stack.save()
            }
        }
    }
    
    func isObjectInContext(item: Constants.TempItem) -> (Bool, [Item]?) {
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
            print("SHIT JUST HAPPENED")
        }
        return (false, nil)
    }
    

}
