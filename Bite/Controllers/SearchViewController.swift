//
//  SearchViewController.swift
//  Bite
//
//  Created by Jamie Nguyen on 2/23/18.
//  Copyright © 2018 Jamie Nguyen. All rights reserved.
//

import UIKit

protocol SearchViewControllerDelegate {
    func searchItems(_ searchViewController: SearchViewController, didPickItem item: Item?)
}

class SearchViewController: UIViewController {
    
    // MARK: Properties
    
    // the data for the table
    var items = [Client.Constants.TempItem]()
    var selectedItem: Client.Constants.TempItem?
    // the delegate will typically be a view controller, waiting for the Item Picker to return an movie
    var delegate: SearchViewControllerDelegate?
    
    // the most recent data download task. We keep a reference to it so that it can be canceled every time the search text changes
    var searchTask: URLSessionDataTask?
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var itemTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set up Network Activity Indicator
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        // configure tap recognizer
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)
        self.navigationController!.navigationBar.topItem!.title = ""
    }
    // MARK: Dismissals
    
    @IBAction func openLogs(_ sender: Any) {
        performSegue(withIdentifier: "logSegue", sender: self)
    }
    @objc func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    private func cancel() {
        delegate?.searchItems(self, didPickItem: nil)
        logout()
    }
    
    func logout() {
        dismiss(animated: true, completion: nil)
    }

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
        if Client.sharedInstance.isInternetAvailable() {
            debugPrint("Searching")
        // new search
            searchTask = Client.sharedInstance.getFoodFromNutritionix(item: searchText) { (items, error) in
                self.searchTask = nil
                if let items = items {
                    self.items = items
                    DispatchQueue.main.async {
                        self.itemTableView!.reloadData()
                    }
                }
            }
        } else {
            debugPrint("No network connection")
            Client.sharedInstance.showAlertMessage(title: "", message: "The internet connection appears to be offline", viewController: self)
        }
            
    }
    
    // Dismiss keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}


// MARK: - SearchViewController: UITableViewDelegate, UITableViewDataSource

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellReuseId = "itemCell"
        let item = items[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseId) as! ItemViewCell
        cell.itemLabel.text = item.name
        cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 2
        if let url = item.image_url {
            let ai = ActivityIndicator()
            ai.showLoader(cell.itemImageView)
            let _ = downloadImage(imagePath: url) { (data, errorString) in
                if errorString == nil {
                    self.items[(indexPath as NSIndexPath).row].image = UIImage(data: data!)
                    DispatchQueue.main.async {
                        ai.removeLoader()
                        cell.itemImageView.image = UIImage(data: data!)
                    }
                } else {
                    ai.removeLoader()
                }
            }
        } else {
            cell.itemImageView.image = nil
        }
        cell.itemImageView.layer.cornerRadius = cell.itemImageView.frame.height / 2
        cell.itemImageView.backgroundColor = UIColor.black
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
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

