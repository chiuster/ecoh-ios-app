//
//  VenueDetailViewController.swift
//  ecoh
//
//  Created by Ryan Chiu on 8/23/16.
//  Copyright © 2016 Ecoh Technologies, LLC. All rights reserved.
//

import UIKit
import CoreLocation
import AddressBookUI
import MapKit

import Firebase
import GooglePlaces

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class VenueDetailViewController : UIViewController {
    
    // Specific venue details
    var name = ""
    var address = ""
    var latitude = 0.0
    var longitude = 0.0
    var placeID = "" // Google Places ID
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var directionsButton: UIButton!

    @IBOutlet weak var orderButton: UIBarButtonItem!
    
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var priceLevelLabel: UILabel!
    
    @IBOutlet weak var happyHourLabel: UILabel!
    @IBOutlet weak var websiteButton: UIButton!
    
    var ref = FIRDatabaseReference()
    
    var ratings: [Int] = []
    var website: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = name
        self.addressLabel.text = address
        self.setupAesthetics()
        self.loadFirstPhotoForPlace(placeID)
        
        self.ref = FIRDatabase.database().reference()
        
        print("Looking up venue with placeID \(self.placeID) ...")
        loadData()
        
        print("Latitude: \(latitude) and longitude: \(longitude)")
    }
    
    @IBAction func goToWebsite(_ sender: AnyObject) {
        UIApplication.shared.openURL(URL(string: self.website)!)
    }
    
    func loadData() {
        let placesClient: GMSPlacesClient = GMSPlacesClient()
        
        placesClient.lookUpPlaceID(self.placeID, callback: { (place: GMSPlace?, error: Error?) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                self.addressLabel.text = place.formattedAddress
                
                if let phone = place.phoneNumber {
                    self.phoneLabel.text = phone
                }
                
                if let website = place.website {
                    self.website = website.absoluteString
                    self.websiteLabel.text = website.absoluteString.replacingOccurrences(of: "http://", with: "www.").replacingOccurrences(of: "https://", with: "www.")
                    self.websiteButton.isHidden = false
                }
                
                switch (place.priceLevel.rawValue) {
                    case 0:
                        self.priceLevelLabel.text = "$"
                    case 1:
                        self.priceLevelLabel.text = "$$"
                    case 2:
                        self.priceLevelLabel.text = "$$$"
                    case 3:
                        self.priceLevelLabel.text = "$$$$"
                    case 4:
                        self.priceLevelLabel.text = "$$$$$"
                    default:
                        self.priceLevelLabel.text = "Varies"
                }
                
            } else {
                print("No place details for \(self.placeID)")
            }
        } as! GMSPlaceResultCallback)
        
        
        ref.child("venues").child(self.placeID).observe(.value, with: { snapshot in
            let snapshotValue = snapshot.value as? NSDictionary
            if let specials = snapshotValue?["specials"] as! String? {
                self.happyHourLabel.text = specials
            }
        })
    }
    
    @IBAction func getDirections(_ sender: AnyObject) {
        showOnMaps()
    }
    
    func loadFirstPhotoForPlace(_ placeID: String) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \((error as NSError).description)")
            } else {
                if let firstPhoto = photos?.results.first {
                    self.loadImageForMetadata(firstPhoto)
                }
            }
        }
    }
    
    func loadImageForMetadata(_ photoMetadata: GMSPlacePhotoMetadata) {
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, constrainedTo: imageView.bounds.size, scale: self.imageView.window!.screen.scale) { (photo, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \((error as NSError).description)")
            } else {
                self.imageView.image = photo;
            }
        }
    }
    
    func reverseGeocode(_ latitude: Double, longitude: Double, completion: @escaping (_ address: String?) -> Void) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Error in reverse geocoding: \(error)")
                completion("")
            }
            else if placemarks?.count > 0 {
                let pm = placemarks![0]
                completion(ABCreateStringWithAddressDictionary(pm.addressDictionary!, false))
            }
        })
    }
    
    func setupAesthetics() {
        self.navigationController!.navigationBar.tintColor = UIColor.white
        self.directionsButton.layer.cornerRadius = 5
        
        //self.scrollView.contentSize = CGSize(width: 325, height: self.directionsButton.frame.minY)
        self.websiteButton.isHidden = true
    }
    
    // Get directions to address via Apple Maps
    func showOnMaps() {
        let addressDict = [kABPersonAddressStreetKey as String: self.addressLabel.text]
        let place = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: place)
        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMaps(launchOptions: options)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
