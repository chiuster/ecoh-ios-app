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
import GoogleMaps

class VenueDetailViewController : UIViewController {
    
    // Specific venue details
    var name = ""
    var address = ""
    var latitude = 0.0
    var longitude = 0.0
    var placeID = "" // Google Places ID
    var venueID = "" // Firebase Database ID
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var directionsButton: UIButton!

    @IBOutlet weak var scrollView: UIScrollView!
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
        
        loadData()
    }
    
    @IBAction func goToWebsite(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: self.website)!)
    }
    
    func loadData() {
        let placesClient: GMSPlacesClient = GMSPlacesClient()
        
        placesClient.lookUpPlaceID(self.placeID, callback: { (place: GMSPlace?, error: NSError?) -> Void in
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
                    self.websiteLabel.text = website.absoluteString.stringByReplacingOccurrencesOfString("http://", withString: "www.").stringByReplacingOccurrencesOfString("https://", withString: "www.")
                    self.websiteButton.hidden = false
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
        })
        
        
        ref.child("venues").child(self.venueID).observeEventType(.Value, withBlock: { snapshot in
            if let specials = snapshot.value!["specials"] as! String? {
                self.happyHourLabel.text = specials
            }
        })
    }
    
    @IBAction func getDirections(sender: AnyObject) {
        showOnMaps()
    }
    
    func loadFirstPhotoForPlace(placeID: String) {
        GMSPlacesClient.sharedClient().lookUpPhotosForPlaceID(placeID) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.description)")
            } else {
                if let firstPhoto = photos?.results.first {
                    self.loadImageForMetadata(firstPhoto)
                }
            }
        }
    }
    
    func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata) {
        GMSPlacesClient.sharedClient().loadPlacePhoto(photoMetadata, constrainedToSize: imageView.bounds.size, scale: self.imageView.window!.screen.scale) { (photo, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.description)")
            } else {
                self.imageView.image = photo;
            }
        }
    }
    
    func reverseGeocode(latitude: Double, longitude: Double, completion: (address: String?) -> Void) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Error in reverse geocoding: \(error)")
                completion(address: "")
            }
            else if placemarks?.count > 0 {
                let pm = placemarks![0]
                completion(address: ABCreateStringWithAddressDictionary(pm.addressDictionary!, false))
            }
        })
    }
    
    func setupAesthetics() {
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.directionsButton.layer.cornerRadius = 5
        
        self.scrollView.contentSize = CGSize(width: 325, height: self.directionsButton.frame.minY)
        self.websiteButton.hidden = true
    }
    
    // Get directions to address via Apple Maps
    func showOnMaps() {
        let addressDict = [kABPersonAddressStreetKey as String: address]
        let place = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: place)
        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMapsWithLaunchOptions(options)
    }
    
    func showOnMaps(address: String, latitude: Double, longitude: Double) {
        let addressDict = [kABPersonAddressStreetKey as String: address]
        let place = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: place)
        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMapsWithLaunchOptions(options)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
