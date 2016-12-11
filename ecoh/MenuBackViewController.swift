//
//  MenuBackViewController.swift
//  ecoh
//
//  Created by Ryan Chiu on 9/5/16.
//  Copyright © 2016 Ecoh Technologies, LLC. All rights reserved.
//

import Foundation
import Firebase

class MenuBackViewController: UITableViewController {
    
    var tableArray = [String]()
    
    override func viewDidLoad() {
        tableArray = ["Home", "Profile", "Referrals", "Logout"]
        self.tableView.backgroundColor = UIColor(red: 0.235, green: 0.275, blue: 0.392, alpha: 0.5)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = tableArray[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.font = UIFont(name: "Avenir Next", size: 22)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == 0) {
            self.performSegueWithIdentifier("menuToMap", sender: nil)
        } else if (indexPath.row == 1) {
            self.performSegueWithIdentifier("menuToProfile", sender: nil)
        } else if (indexPath.row == 2) {
            self.performSegueWithIdentifier("menuToReferrals", sender: nil)
        } else {
            // Clear NSUserDefaults for emails and passwords
            NSUserDefaults.standardUserDefaults().removeObjectForKey("email")
            NSUserDefaults.standardUserDefaults().removeObjectForKey("password")
            
            try! FIRAuth.auth()!.signOut()
            
            self.performSegueWithIdentifier("logout", sender: nil)
        }
    }
}
