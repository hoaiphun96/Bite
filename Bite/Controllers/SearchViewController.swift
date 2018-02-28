//
//  SearchViewController.swift
//  Bite
//
//  Created by Jamie Nguyen on 2/23/18.
//  Copyright © 2018 Jamie Nguyen. All rights reserved.
//

import UIKit

protocol SearchViewControllerDelegate {
    func searchItems(_ searchViewController: SearchViewController, didPickMovie movie: Item?)
}

class SearchViewController: UIViewController {
    
    // MARK: Properties
    
    // the data for the table
    var items = [Constants.TempItem]()
    var selectedItem: Constants.TempItem?
    // the delegate will typically be a view controller, waiting for the Movie Picker to return an movie
    var delegate: SearchViewControllerDelegate?
    
    // the most recent data download task. We keep a reference to it so that it can be canceled every time the search text changes
    var searchTask: URLSessionDataTask?
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var itemTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // configure tap recognizer
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)
    }
    // MARK: Dismissals
    
    @IBAction func openLogs(_ sender: Any) {
        performSegue(withIdentifier: "logSegue", sender: self)
    }
    @objc func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    private func cancel() {
        delegate?.searchItems(self, didPickMovie: nil)
        logout()
    }
    
    func logout() {
        dismiss(animated: true, completion: nil)
    }
   

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - SearchViewController: UIGestureRecognizerDelegate

extension SearchViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return searchBar.isFirstResponder
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // cancel the last task
        if let task = searchTask {
            task.cancel()
        }
        
        // if the text is empty we are done
        if searchText == "" {
            return
        }
        
        // new search
        searchTask = SearchFood.sharedInstance.getFoodFromNutritionix(item: searchText) { (items, error) in
            self.searchTask = nil
            if let items = items {
                self.items = items
                DispatchQueue.main.async {
                    self.itemTableView!.reloadData()
                }
            }
        }
    }
}


// MARK: - SearchViewController: UITableViewDelegate, UITableViewDataSource

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellReuseId = "itemCell"
        let item = items[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseId) as! ItemViewCell
        cell.itemLabel.text = item.name
        if let url = item.image_url {
            let _ = downloadImage(imagePath: url) { (data, errorString) in
                if errorString == nil {
                    DispatchQueue.main.async {
                        cell.itemImageView.image = UIImage(data: data!)
                    }
                }
            }
        }
        return cell
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedItem = items[(indexPath as NSIndexPath).row]
        performSegue(withIdentifier: "detailSegue", sender: self)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "detailSegue" {
            
            if let detailVC = segue.destination as? DetailViewController {
                detailVC.item = selectedItem
            }
        }
    
    }
    
}

