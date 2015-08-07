//
//  QueryTableViewController.swift
//  PM25
//
//  Created by Ben Lu on 8/5/15.
//  Copyright © 2015 DJ.Ben. All rights reserved.
//

import UIKit
import PM25

let CitySegueIdentifier = "CitySegue"
let AllDetailSegueIdentifier = "AllDetailSegue"

class QueryTableViewController: UITableViewController {
    
    private let queries: [String: PM25.Query] = [
        "Cities": Query.CityNames,
        "All City Details": Query.AllCityDetails,
        "All City Ranking": Query.AllCityRanking
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return queries.keys.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("QueryCell", forIndexPath: indexPath)
        let titles = queries.keys.array
        let title = titles[indexPath.row]
        cell.textLabel?.text = title
        return cell
    }

    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch queryForIndexPath(indexPath) {
        case .CityNames:
            performSegueWithIdentifier(CitySegueIdentifier, sender: indexPath)
        default:
            let alert = UIAlertController(title: "Limited API", message: "This API call can only be called 20 times per day, are you sure you want to invoke it?", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (_) -> Void in
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }))
            alert.addAction(UIAlertAction(title: "Continue", style: .Default, handler: { (_) -> Void in
                self.performSegueWithIdentifier(AllDetailSegueIdentifier, sender: indexPath)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case CitySegueIdentifier:
            let indexPath = sender as! NSIndexPath
            let query = queryForIndexPath(indexPath)
            let vc = segue.destinationViewController as! CityTableViewController
            vc.navigationItem.title = queries.keys.array[indexPath.row]
            vc.query = query
        case AllDetailSegueIdentifier:
            let indexPath = sender as! NSIndexPath
            let query = queryForIndexPath(indexPath)
            let vc = segue.destinationViewController as! AllDetailTableViewController
            vc.query = query
            vc.navigationItem.title = queries.keys.array[indexPath.row]
        default:
            break
        }
    }
    
    // MARK: - Helper methods
    
    private func queryForIndexPath(indexPath: NSIndexPath) -> Query {
        let array = queries.keys.array
        return queries[array[indexPath.row]]!
    }

}
