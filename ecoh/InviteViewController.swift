//
//  InviteViewController.swift
//  ecoh
//
//  Created by Ryan Chiu on 9/28/16.
//  Copyright © 2016 Ecoh Technologies, LLC. All rights reserved.
//

import UIKit
import AddressBook

import Firebase

class InviteViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var promoCodeLabel: UILabel!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    //@IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var pointsLabel: UILabel!
    
    //@IBOutlet weak var tableView: UITableView!
    
    var contactNames: [String] = ["Contact 1", "Contact 2", "Contact 3", "Contact 4", "Contact 5"]
    var phoneNumbers: [String] = ["(847)-445-7886", "(847)-433-4354", "(847)-123-5435", "(800)-123-5435", "(888)-123-5435"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        self.menuButton.target = self.revealViewController()
        self.menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        self.setupAesthetics()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let uid = FIRAuth.auth()?.currentUser?.uid
        let ref = FIRDatabase.database().reference()
        
        // Load promo code
        ref.child("users").child(uid!).observeSingleEvent(of: .childAdded, with: { (snapshot) in
            // Get user value
            if let promo = snapshot.value as? String {
                self.promoCodeLabel.text = promo
            } else {
                self.promoCodeLabel.text = "CODE1"
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        // Load user points
        ref.child("users").child(uid!).child("userInfo").observeSingleEvent(of: .value, with: { (snapshot) in
            let snapshotValue = snapshot.value as? NSDictionary
            if let points = snapshotValue?["points"] as? Int {
                self.pointsLabel.text = "\(points)"
            } else {
                self.pointsLabel.text = "0"
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func showAlert(_ title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupAesthetics() {
        self.promoCodeLabel.layer.borderColor = UIColor.white.cgColor
        self.promoCodeLabel.layer.borderWidth = 2
        self.promoCodeLabel.layer.cornerRadius = 5
        
        self.navigationController!.navigationBar.tintColor = UIColor.white
        
        //self.tableView.setEditing(true, animated: true)
        //self.sendButton.enabled = false
    }
    
    @IBAction func share(_ sender: AnyObject) {
        let shareText = ["Check out Ecoh, the social guide! Use the following code for a free drink: \(self.promoCodeLabel.text!)", "http://www.ecohapp.com"]
        let controller: UIActivityViewController = UIActivityViewController(activityItems: shareText, applicationActivities: nil)
        self.present(controller, animated: true, completion: nil)
    }
    
    /*func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactNames.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = contactNames[indexPath.row]
        cell.detailTextLabel?.text = phoneNumbers[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Top)
        print("Selected row \(indexPath)")
        
        self.sendButton.enabled = true
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        //self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        print("Deselected row \(indexPath)")
    }
    
    func tableView(tableView: UITableView!, editingStyleForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCellEditingStyle {
        return unsafeBitCast(3, UITableViewCellEditingStyle.self)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.textLabel?.font = UIFont(name: "Avenir Next", size: 18)
        cell.detailTextLabel?.font = UIFont(name: "Avenir Next", size: 14)
        cell.detailTextLabel?.textColor = UIColor.grayColor()
    }*/
}
