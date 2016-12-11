//
//  LoginViewController.swift
//  ecoh
//
//  Created by Ryan Chiu on 5/29/16.
//  Copyright © 2016 Ecoh Technologies, LLC. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class LoginViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.setupAesthetics()
    }
    
    @IBAction func forgotPassword(sender: AnyObject) {
        let alert = UIAlertController(title: "Recover Password", message: "Enter your email address.", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = ""
        })
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            if textField.text! == "" || !textField.text!.containsString("@")
            {
                let alertController = UIAlertController(title: "Oops!", message: "Please enter a valid email address.", preferredStyle: .Alert)
                let defaultAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            else
            {
                FIRAuth.auth()?.sendPasswordResetWithEmail(textField.text!, completion: { (error) in
                    var title = ""
                    var message = ""
                    
                    if error != nil
                    {
                        title = "Oops!"
                        message = (error?.localizedDescription)!
                    }
                    else
                    {
                        title = "Success!"
                        message = "Password reset email sent."
                        textField.text = ""
                    }
                    
                    let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            }
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func login(sender: AnyObject) {
        let email = usernameField.text
        let password = passwordField.text
        
        view.endEditing(true)
        self.loadingView.hidden = false
        
        // Check for enabled location services
        if CLLocationManager.locationServicesEnabled() {
            // Check to see if user is in available app areas
            if userInEnabledRegion() {
                FIRAuth.auth()?.signInWithEmail(email!, password: password!) { (user, error) in
                    if error != nil {
                        let alertController = UIAlertController(title: "Invalid Username/Password", message: "We're sorry, but either your username or password is entered incorrectly.", preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default,handler: nil))
                
                        self.presentViewController(alertController, animated: true, completion: nil)
                        self.loadingView.hidden = true
                    } else {
                        // Save info in case user exits app -- no longer have to login again
                        let defaults = NSUserDefaults.standardUserDefaults()
                        defaults.setObject(email!, forKey: "email")
                        defaults.setObject(password!, forKey: "password")
                        defaults.synchronize()
                
                        self.performSegueWithIdentifier("login", sender: nil)
                    }
                }
            } else {
                let alertController = UIAlertController(title: "App Not Yet Available In Your Area", message:
                    "Sorry, but we're not in your area yet! Please check back for updates via our website (http://www.ecohapp.com), as we are coming to you soon!", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                self.loadingView.hidden = true
            }
        } else {
            let alertController = UIAlertController(title: "Location Services Not Enabled", message:
                "We're sorry, but you need to allow us to use your location. You can do this through your phone's settings.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            self.loadingView.hidden = true
        }
    }
    
    // Changing Status Bar
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        // LightContent
        return UIStatusBarStyle.LightContent
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func userInEnabledRegion() -> Bool {
        // Chicago, IL
        if let location = self.locationManager.location {
            if (self.locationManager.location!.coordinate.latitude < 42.023722 && self.locationManager.location!.coordinate.latitude > 41.662509 && self.locationManager.location!.coordinate.longitude < -87.523956 && self.locationManager.location!.coordinate.longitude > -87.846680) {
                return true
            } else {
                return false
            }
        } else {
            
        }
        return false
    }
    
    func setupAesthetics() {
        self.loadingView.hidden = true
        self.loadingView.layer.masksToBounds = false
        self.loadingView.clipsToBounds = true
        self.loadingView.layer.cornerRadius = 5
        self.activityIndicator.startAnimating()
        
        self.loginButton.layer.cornerRadius = 5
        self.hideKeyboardWhenTappedAround()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

