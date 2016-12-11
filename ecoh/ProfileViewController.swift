//
//  ProfileViewController.swift
//  ecoh
//
//  Created by Ryan Chiu on 7/27/16.
//  Copyright © 2016 Ecoh Technologies, LLC. All rights reserved.
//

import UIKit

import Firebase

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField1: UITextField!
    @IBOutlet weak var passwordField2: UITextField!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        self.menuButton.target = self.revealViewController()
        self.menuButton.action = Selector("revealToggle:")
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        self.setupAesthetics()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.loadingView.hidden = false
        self.activityIndicator.startAnimating()
        
        // Pull current user info from Firebase and pre-fill fields
        let uid = FIRAuth.auth()?.currentUser?.uid
        let ref = FIRDatabase.database().reference()
        
        ref.child("users").child(uid!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            let userPhoto = snapshot.value!["userPhoto"] as? String
            
            if userPhoto != nil {
                let url = NSURL(string: userPhoto!)
                if let data = NSData(contentsOfURL: url!) {
                    self.profilePicture.image = UIImage(data: data)
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        ref.child("users").child(uid!).child("userInfo").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            // Get user value
            let firstName = snapshot.value!["firstName"] as! String
            let lastName = snapshot.value!["lastName"] as! String
            let email = FIRAuth.auth()?.currentUser?.email!
            
            self.firstNameField.text = firstName
            self.lastNameField.text = lastName
            self.emailField.text = email
            
            self.loadingView.hidden = true
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    @IBAction func changeProfilePicture(sender: AnyObject) {
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self
        myPickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        self.presentViewController(myPickerController, animated: true, completion: nil)
    }
    
    @IBAction func saveProfile(sender: AnyObject) {
        let firstName = self.firstNameField.text
        let lastName = self.lastNameField.text
        let email = self.emailField.text
        let password1 = self.passwordField1.text
        let password2 = self.passwordField2.text
        
        self.loadingView.hidden = false
        
        // Check if user wanted to change password (i.e. if password1 & password2 != "")
        if (verifyFields(firstName!, lastName: lastName!, email: email!, password1: password1!, password2: password2!)) {
            if (password1 != "" && password2 != "") {
                // User wants to change password
                // Update user password
                FIRAuth.auth()?.currentUser?.updatePassword(password1!) { error in
                    if error != nil {
                        // An error happened.
                    } else {
                        // Password updated.
                    }
                }
            }
            
            // Update email
            FIRAuth.auth()?.currentUser?.updateEmail(email!) { error in
                if error != nil {
                    // An error happened.
                } else {
                    // Password updated.
                }
            }
            
            // Update first and last name
            let uid = FIRAuth.auth()?.currentUser?.uid
            let ref = FIRDatabase.database().reference()
            ref.child("users").child(uid!).child("userInfo").setValue(["firstName": firstName!, "lastName": lastName!])
            
            self.loadingView.hidden = true
        }
    }
    
    // Checks if all filled out fields meet requirements before saving to Firebase
    func verifyFields(firstName: String, lastName: String, email: String, password1: String, password2: String) -> Bool {
        if (firstName == "" || lastName == "") {
            showAlert("Name Empty", message: "Please fill out your first and last name.")
            return false
        } else if (!email.containsString("@")) {
            showAlert("Invalid Email", message: "Please enter a valid email address.")
            return false
        } else if (password1 != password2) {
            showAlert("Passwords Don't Match", message: "Sorry, but your entered passwords do not match.")
            return false
        } else if (password1 as NSString!).length < 5 && (password1 as NSString!).length > 0 {
            showAlert("Password Too Short", message: "Passwords must be at least five (5) characters long.")
            return false
        }
        return true
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // Set local profile picture first, the upload file onto Firebase
        let localFile = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        self.profilePicture.image = localFile
        self.profilePicture.layer.cornerRadius = 50.0
        self.dismissViewControllerAnimated(true, completion: nil)
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        let storageRef = FIRStorage.storage().referenceForURL("gs://project-64989311639038962.appspot.com/\(uid).jpg")
        let databaseRef = FIRDatabase.database().reference()
        
        var data = NSData()
        data = UIImageJPEGRepresentation(localFile!, 0.8)!
        
        storageRef.putData(data, metadata: nil) { metadata, error in
            if (error != nil) {
                // Uh-oh, an error occurred!
                print("Profile picture upload error: \(error)")
            } else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = metadata!.downloadURL()?.absoluteString
                databaseRef.child("users").child(uid!).updateChildValues(["userPhoto": downloadURL!])
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupAesthetics() {
        self.profilePicture.layer.masksToBounds = false
        self.profilePicture.clipsToBounds = true
        self.profilePicture.layer.cornerRadius = 50.0
        
        self.saveButton.layer.cornerRadius = 5
        
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor();
        
        self.loadingView.layer.masksToBounds = false
        self.loadingView.clipsToBounds = true
        self.loadingView.layer.cornerRadius = 5
        self.activityIndicator.startAnimating() // and then just hide/show loadingView as needed
    }
}