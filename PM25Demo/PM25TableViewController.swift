//
//  PM25TableViewController.swift
//  PM25
//
//  Created by Sihao Lu on 8/11/15.
//  Copyright © 2015 DJ.Ben. All rights reserved.
//

import UIKit
import PM25

class PM25TableViewController: UITableViewController {
    
    var query: Query!
    var result: Result?
    
    func loadQuery() {
        query.executeWithCompletion { (result, error) -> Void in
            guard error == nil else {
                print("\(error)")
                self.promptError(error!)
                return
            }
            self.result = result
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
        }
    }
    
    func promptError(error: NSError) {
        let title: String? = "Error"
        let message: String?
        switch error.code {
        case PM25Query.PM25QueryError.APICallLimitReached._code:
            message = "API call limit reached. Please have a rest."
        case PM25Query.PM25QueryError.AuthenticationFailed._code:
            message = "Authentication failed."
        default:
            message = "Uncaught error \(error)"
            break
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (_) -> Void in
            self.navigationController?.popViewControllerAnimated(true)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }

}
