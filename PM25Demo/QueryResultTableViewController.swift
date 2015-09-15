//
//  QueryResultTableViewController.swift
//  PM25
//
//  Created by Sihao Lu on 8/11/15.
//  Copyright © 2015 DJ.Ben. All rights reserved.
//

import UIKit
import PM25

let QueryResultCellIdentifier = "QueryResultCell"
let QueryResultStationCellIdentifier = "QueryResultStationCell"
let QueryStationDetailSegueIdentifier = "QueryStationDetail"

class QueryResultTableViewController: PM25TableViewController {
    
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
        return result?.samples?.count ?? result?.monitoringStations?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.detailTextLabel?.numberOfLines = 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if let pm25Query = query as? PM25Query {
            switch pm25Query {
            case PM25Query.StationList(_):
                cell = tableView.dequeueReusableCellWithIdentifier(QueryResultStationCellIdentifier, forIndexPath: indexPath)
                let station = result!.monitoringStations![indexPath.row]
                cell.textLabel?.text = "\(station)"
            default:
                cell = tableView.dequeueReusableCellWithIdentifier(QueryResultCellIdentifier, forIndexPath: indexPath)
                let sample = result!.samples![indexPath.row]
                cell.textLabel?.text = sample.isAverageSample ? "City average" : "\(sample.station!)"
                cell.detailTextLabel?.text = "\(sample)"
            }
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier(QueryResultCellIdentifier, forIndexPath: indexPath)
            let sample = result!.samples![indexPath.row]
            cell.textLabel?.text = "US embassy"
            cell.detailTextLabel?.text = "\(sample)"
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let pm25Query = query as? PM25Query {
            switch pm25Query {
            case .CityDetails(_), .StationDetails(_):
                return 80
            default:
                return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
            }
        }
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case QueryStationDetailSegueIdentifier:
            let vc = segue.destinationViewController as! QueryResultTableViewController
            let selectedIndexPath = tableView.indexPathForCell(sender as! UITableViewCell)!
            let station = result!.monitoringStations![selectedIndexPath.row]
            vc.query = PM25Query.StationDetails(stationCode: station.code)
        default:
            break
        }
    }
    

}
