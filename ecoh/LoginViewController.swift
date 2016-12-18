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
    
    @IBAction func forgotPassword(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Recover Password", message: "Enter your email address.", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.text = ""
        })
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            if textField.text! == "" || !textField.text!.contains("@")
            {
                let alertController = UIAlertController(title: "Oops!", message: "Please enter a valid email address.", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
            else
            {
                FIRAuth.auth()?.sendPasswordReset(withEmail: textField.text!, completion: { (error) in
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
                    
                    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                })
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func login(_ sender: AnyObject) {
        let email = usernameField.text
        let password = passwordField.text
        
        view.endEditing(true)
        self.loadingView.isHidden = false
        
        // Check for enabled location services
        if CLLocationManager.locationServicesEnabled() {
            // Check to see if user is in available app areas
            FIRAuth.auth()?.signIn(withEmail: email!, password: password!) { (user, error) in
                if error != nil {
                    let alertController = UIAlertController(title: "Invalid Username/Password", message: "We're sorry, but either your username or password is entered incorrectly.", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default,handler: nil))
                
                    self.present(alertController, animated: true, completion: nil)
                    self.loadingView.isHidden = true
                } else {
                    // Save info in case user exits app -- no longer have to login again
                    let defaults = UserDefaults.standard
                    defaults.set(email!, forKey: "email")
                    defaults.set(password!, forKey: "password")
                    defaults.synchronize()
            
                    self.performSegue(withIdentifier: "login", sender: nil)
                }
            }
        } else {
            let alertController = UIAlertController(title: "Location Services Not Enabled", message:
                "We're sorry, but you need to allow us to use your location. You can do this through your phone's settings.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
            self.loadingView.isHidden = true
        }
    }
    
    // Changing Status Bar
    override var preferredStatusBarStyle : UIStatusBarStyle {
        // LightContent
        return UIStatusBarStyle.lightContent
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }

    func setupAesthetics() {
        self.loadingView.isHidden = true
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

