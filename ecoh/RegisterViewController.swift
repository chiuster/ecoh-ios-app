//
//  RegisterViewController.swift
//  ecoh
//
//  Created by Ryan Chiu on 5/30/16.
//  Copyright © 2016 Ecoh Technologies, LLC. All rights reserved.
//

// ADD: first name, last name, dob, full address

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var inviteCodeField: UITextField!
    
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.setupAesthetics()
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func register(sender: AnyObject) {
        let email = emailField.text
        let password = passwordField.text
        let firstName = firstNameField.text
        let lastName = lastNameField.text
        let inviteCode = inviteCodeField.text
        
        // Check if any fields are empty
        if (email == "" || password == "" || firstName == "" || lastName == "") {
            let alertController = UIAlertController(title: "Incomplete Fields", message:
                "Make sure you fill out all required fields!", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        // Make sure passwords are >= 5 chars long
        else if ((password as NSString!).length < 5) {
            let alertController = UIAlertController(title: "Password Too Short", message:
                "Passwords must be at least 5 characters in length.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        else {
            FIRAuth.auth()?.createUserWithEmail(email!, password: password!, completion: { user, error in
                // If something STILL went wrong:
                if error != nil {
                    if error!.code == FIRAuthErrorCode.ErrorCodeEmailAlreadyInUse.rawValue {
                        let alertController = UIAlertController(title: "Email In Use", message:
                            "We're sorry, but there's already an account associated with that email address.", preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default,handler: nil))
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                    } else if error!.code == FIRAuthErrorCode.ErrorCodeInvalidEmail.rawValue {
                        let alertController = UIAlertController(title: "Invalid Email", message:
                            "We're sorry, but that doesn't seem to be a valid email address.", preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default,handler: nil))
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                    } else {
                        if error!.code == FIRAuthErrorCode.ErrorCodeEmailAlreadyInUse.rawValue {
                            let alertController = UIAlertController(title: "Unknown error", message:
                                "Please check back in a few minutes. We apologize for the inconvenience.", preferredStyle: UIAlertControllerStyle.Alert)
                            alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default,handler: nil))
                            
                            self.presentViewController(alertController, animated: true, completion: nil)
                        }
                    }
                }
                    
                else if (inviteCode! == "") {
                    FIRAuth.auth()?.signInWithEmail(email!, password: password!, completion: nil)
                    
                    let uid = FIRAuth.auth()?.currentUser!.uid
                    let ref = FIRDatabase.database().reference()
                    ref.child("users").child(uid!).child("userInfo").setValue(["email": email!, "firstName": firstName!, "lastName": lastName!, "points": 0, "signup_bonus_redeemed": 0])
                    
                    self.performSegueWithIdentifier("registered", sender: nil)
                }
                
                // It worked!
                else {
                    FIRAuth.auth()?.signInWithEmail(email!, password: password!, completion: nil)
                    
                    // Grab new user's ID
                    let uid = FIRAuth.auth()?.currentUser!.uid
                    
                    let ref = FIRDatabase.database().reference()
                    
                    ref.child("promos").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                        if (snapshot.hasChild(inviteCode!)) {
                            ref.child("promos").child(inviteCode!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                                // If promo code is valid
                                if let user_id = snapshot.value!["user_id"] as? String {
                                    // Grant invitee points
                                    ref.child("users").child(uid!).child("userInfo").setValue(["email": email!, "firstName": firstName!, "lastName": lastName!, "points": 100, "signup_bonus_redeemed": 1])
                            
                                    // Grant inviter points
                                    ref.child("users").child(user_id).child("userInfo").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                                        let points = snapshot.value!["points"] as! Int
                                        ref.child("users").child(user_id).child("userInfo").updateChildValues(["points": points + 100])
                                    })
                                } else {
                                    // If promo code is invalid
                                    ref.child("users").child(uid!).child("userInfo").setValue(["email": email!, "firstName": firstName!, "lastName": lastName!, "points": 0, "signup_bonus_redeemed": 0])
                                }
                            }) { (error) in
                                print(error.localizedDescription)
                            }
                        }
                    })
                    
                    self.performSegueWithIdentifier("registered", sender: nil)
                }
            })
        }
    }
    
    func setupAesthetics() {
        self.registerButton.layer.cornerRadius = 5
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Changing Status Bar
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    //override func preferredStatusBarStyle() -> UIStatusBarStyle {
        // LightContent
    //    return UIStatusBarStyle.LightContent
    //}
}

