//
//  CityQueryTableViewController.swift
//  PM25
//
//  Created by Sihao Lu on 8/11/15.
//  Copyright © 2015 DJ.Ben. All rights reserved.
//

import UIKit
import PM25

let CityQueryCellIdentifier = "CityQueryCell"
let QueryResultSegueIdentifier = "QueryResultSegue"

class CityQueryTableViewController: UITableViewController {
    
    var city: String!
    
    lazy private var queries: [String: PM25.Query] = {
        return [
            "City stations": Query.StationList(city: self.city),
            "City PM 2.5": Query.CityPM2_5(city: self.city, fields: .Default),
            "City PM 10": Query.CityPM10(city: self.city, fields: .Default),
            "City O3": Query.CityO3(city: self.city, fields: .Default),
            "City NO2": Query.CityNO2(city: self.city, fields: .Default),
            "City CO": Query.CityCO(city: self.city, fields: .Default),
            "City SO2": Query.CitySO2(city: self.city, fields: .Default),
            "City AQI": Query.CityAQI(city: self.city, fields: .Default),
            "City details": Query.CityDetails(city: self.city)
        ]
    }()

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
        return queries.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CityQueryCellIdentifier, forIndexPath: indexPath)
        let title = queries.keys.array[indexPath.row]
        cell.textLabel?.text = title
        return cell
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case QueryResultSegueIdentifier:
            let vc = segue.destinationViewController as! QueryResultTableViewController
            let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)!
            let title = queries.keys.array[indexPath.row]
            vc.query = queries[title]
            vc.navigationItem.title = title
        default:
            break
        }
    }
    

}
