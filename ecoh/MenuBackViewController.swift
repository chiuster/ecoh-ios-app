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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = tableArray[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.font = UIFont(name: "Avenir Next", size: 22)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0) {
            self.performSegue(withIdentifier: "menuToMap", sender: nil)
        } else if (indexPath.row == 1) {
            self.performSegue(withIdentifier: "menuToProfile", sender: nil)
        } else if (indexPath.row == 2) {
            self.performSegue(withIdentifier: "menuToReferrals", sender: nil)
        } else {
            // Clear NSUserDefaults for emails and passwords
            UserDefaults.standard.removeObject(forKey: "email")
            UserDefaults.standard.removeObject(forKey: "password")
            
            try! FIRAuth.auth()!.signOut()
            
            self.performSegue(withIdentifier: "logout", sender: nil)
        }
    }
}
