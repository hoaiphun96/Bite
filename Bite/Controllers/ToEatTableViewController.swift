//
//  ToEatTableViewController.swift
//  Bite
//
//  Created by Jamie Nguyen on 2/23/18.
//  Copyright © 2018 Jamie Nguyen. All rights reserved.
//

import UIKit
import CoreData

class ToEatTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate  {
    
    @IBOutlet weak var toEatTableView: UITableView!
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            // Whenever the frc changes, we execute the search and
            // reload the table
            fetchedResultsController?.delegate = self
            executeSearch()
            DispatchQueue.main.async {
                self.toEatTableView.reloadData()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        toEatTableView.delegate = self
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        print(try! delegate.stack.context.count(for: fr))
        fr.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        //let pred = NSPredicate(format: "toEat == %@", argumentArray: [true])
        let pred = NSPredicate(format: "toEat == %@", NSNumber(value: true))
        fr.predicate = pred
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: delegate.stack.context , sectionNameKeyPath: nil, cacheName: nil)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(String(describing: fetchedResultsController))")
            }
        }
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if let fc = fetchedResultsController {
            return (fc.sections?.count)!
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let fc = fetchedResultsController {
            print("number of object \(fc.sections![section].numberOfObjects)")
            return fc.sections![section].numberOfObjects
        } else {
            print("0")
            return 0
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = fetchedResultsController?.object(at: indexPath) as! Item
  
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ItemViewCell
        cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 2
        // Configure the cell...
        if item.image != nil  {
            let p = UIImage(data: item.image! as Data)
            cell.itemImageView.image = p
            
        } else { //else download new image
            let ai = ActivityIndicator()
            cell.itemImageView.image = nil
            ai.showLoader(cell.imageView!)
            let _ = item.downloadImage(imagePath: item.image_url!, completionHandler: { (data, errorString) in
                if errorString == nil {
                    item.image = data! as NSData
                    self.delegate.stack.save()
                    DispatchQueue.main.async {
                        ai.removeLoader()
                        cell.itemImageView.image = UIImage(data: data!)
                         cell.itemImageView.layer.cornerRadius = cell.cellView.frame.height / 2
                    }
                } else {
                    ai.removeLoader()
                }
            })
        }
       
        cell.itemLabel.text = item.name
        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
