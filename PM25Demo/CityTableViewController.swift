//
//  CityTableViewController.swift
//  PM25
//
//  Created by Ben Lu on 8/7/15.
//  Copyright © 2015 DJ.Ben. All rights reserved.
//

import UIKit
import PM25

let CityQueryMoreSegueIdentifier = "CityQueryMore"

class CityTableViewController: PM25TableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        loadQuery()
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
        return result?.cities?.count ?? 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CityCell", forIndexPath: indexPath)
        let city = result!.cities![indexPath.row]
        cell.textLabel?.text = city
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.accessoryType = .DisclosureIndicator
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case CityQueryMoreSegueIdentifier:
            let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)!
            let city = result!.cities![indexPath.row]
            let vc = segue.destinationViewController as! CityQueryTableViewController
            vc.city = city
            vc.navigationItem.title = city
        default:
            break
        }
    }
    
}
