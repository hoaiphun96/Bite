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
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        print(try! delegate.stack.context.count(for: fr))
        fr.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let pred = NSPredicate(format: "toEat == %@", NSNumber(value: true))
        fr.predicate = pred
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: delegate.stack.context , sectionNameKeyPath: nil, cacheName: nil)
    }

    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                debugPrint("Error while trying to perform a search: \n\(e)\n\(String(describing: fetchedResultsController))")            }
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let fc = fetchedResultsController {
            return fc.sections![section].numberOfObjects
        } else {
            return 0
        }
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
            ai.showLoader(cell.itemImageView)
            let _ = item.downloadImage(imagePath: item.image_url!, completionHandler: { (data, errorString) in
                if errorString == nil {
                    item.image = data! as NSData
                    self.delegate.stack.save()
                    DispatchQueue.main.async {
                        ai.removeLoader()
                        cell.itemImageView.image = UIImage(data: data!)                    }
                } else {
                    ai.removeLoader()
                }
            })
        }
        cell.itemImageView.layer.cornerRadius = cell.itemImageView.frame.height / 2
        cell.itemLabel.text = item.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if let context = fetchedResultsController?.managedObjectContext, let item = fetchedResultsController?.object(at: indexPath) as? Item, editingStyle == .delete {
            context.delete(item)
            try! context.save()
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        toEatTableView.beginUpdates()
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let set = IndexSet(integer: sectionIndex)
        
        switch (type) {
        case .insert:
            toEatTableView.insertSections(set, with: .fade)
        case .delete:
            toEatTableView.deleteSections(set, with: .fade)
        default:
            // irrelevant in our case
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch(type) {
        case .insert:
            toEatTableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            toEatTableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            toEatTableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            toEatTableView.deleteRows(at: [indexPath!], with: .fade)
            toEatTableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        toEatTableView.endUpdates()
    }

}
