//
//  ViewController.swift
//  ecoh
//
//  Created by Ryan Chiu on 5/28/16.
//  Copyright © 2016 Ecoh Technologies, LLC. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AddressBookUI

import Firebase

import Pulsator
import Mapbox

import SwiftyJSON

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


class ViewController: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MGLMapView!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var vibeButton1: UIButton!
    @IBOutlet weak var vibeButton2: UIButton!
    @IBOutlet weak var vibeButton3: UIButton!
    @IBOutlet weak var vibeButton4: UIButton!
    @IBOutlet weak var vibeButton5: UIButton!
    @IBOutlet weak var mapCenterButton: UIButton!
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let locationManager = CLLocationManager()
    
    // Firebase database reference
    var ref = FIRDatabaseReference()
    
    var vibes: [Vibe] = []
    var venues: [Venue] = []
    
    var nearestVenue: Venue?
    var nearestVenueId: String = ""
    
    var selectedLatitude = 0.0
    var selectedLongitude = 0.0
    var selectedVenueAddress = ""
    var selectedVenueName = ""
    var selectedPlaceID = ""
    var selectedVenueID = ""
    
    var takeButtonPressed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        //self.mapView.showsPointsOfInterest = false
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
        
        self.menuButton.target = self.revealViewController()
        self.menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        //self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())

        // Initialize and load data from Firebase
        self.ref = FIRDatabase.database().reference()
        self.disableRatings()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.setupAesthetics()
        
        print("Vibes loaded: \(self.vibes)")
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "willEnterForeground", name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.mapView.removeAnnotations(self.mapView.annotations)
        //self.vibes = []
        
        self.loadDataJSON() //self.loadData()
    }
    
    // Re-center map on user current location
    @IBAction func centerMap(_ sender: AnyObject) {
        if let coordinate = self.locationManager.location?.coordinate {
            self.mapView.setCenter(coordinate, animated: true)
        }
    }
    
    func disableRatings() {
        self.vibeButton1.isEnabled = false
        self.vibeButton2.isEnabled = false
        self.vibeButton3.isEnabled = false
        self.vibeButton4.isEnabled = false
        self.vibeButton5.isEnabled = false
        
        self.vibeButton1.layer.opacity = 0.6
        self.vibeButton2.layer.opacity = 0.6
        self.vibeButton3.layer.opacity = 0.6
        self.vibeButton4.layer.opacity = 0.6
        self.vibeButton5.layer.opacity = 0.6
    }
    
    func enableRatings() {
        self.vibeButton1.isEnabled = true
        self.vibeButton2.isEnabled = true
        self.vibeButton3.isEnabled = true
        self.vibeButton4.isEnabled = true
        self.vibeButton5.isEnabled = true
        
        self.vibeButton1.layer.opacity = 1.0
        self.vibeButton2.layer.opacity = 1.0
        self.vibeButton3.layer.opacity = 1.0
        self.vibeButton4.layer.opacity = 1.0
        self.vibeButton5.layer.opacity = 1.0
    }
    
    // Return index of vibe with inputted latitude/longitude
    func getIndexOfVibe(_ latitude: Double, longitude: Double) -> Int {
        for vibe in self.vibes {
            if vibe.latitude == latitude && vibe.longitude == longitude {
                return vibes.index(of: vibe)!
            }
        }
        return -1
    }
    
    func loadDataJSON() {
        if let annotations = self.mapView.annotations {
            self.mapView.removeAnnotations(annotations)
        }
        
        let latitude = self.mapView.centerCoordinate.latitude
        let longitude = self.mapView.centerCoordinate.longitude
        
        // calculate approximate radius from mapView's current zoom level
        let radius = Int(20000000 * pow(2.718, self.mapView.zoomLevel * -0.727))
        // ^ b/c radius R = 2E+07e^(-0.727Z), where Z = zoom level

        let browserAPIKey = "AIzaSyBRcPx7Mr9Qvm_IQ0NxYtiQW7TZUDQBnho"
        let dataURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=\(radius)&type=bar&key=\(browserAPIKey)"
        
        if let data = try? Data(contentsOf: URL(string: dataURL)!) {
            let json = JSON(data: data) // JSON array of venues
            
            print("There are \(json["results"].count) bars nearby")
            
            // Now put array data on the map
            for i in 0..<json["results"].count {
                let latitude = json["results"][i]["geometry"]["location"]["lat"].double
                let longitude = json["results"][i]["geometry"]["location"]["lng"].double
                let name = json["results"][i]["name"].string
                let placeID = json["results"][i]["place_id"].string
                
                print("Bar \(i): \(latitude),\(longitude),\(name),\(placeID)")
                
                let id = placeID // might need to change later
                
                if (latitude != nil && longitude != nil && name != nil) {
                    self.venues.append(Venue(id: id!, latitude: latitude!, longitude: longitude!, name: name!, placeID: placeID!))
                }
                
                self.locationManager.startMonitoring(for: CLCircularRegion(center: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!), radius: 20, identifier: name!))
                
                if CLCircularRegion(center: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!), radius: 50, identifier: name!).contains(self.locationManager.location!.coordinate) {
                    self.nearestVenue = Venue(id: id!, latitude: latitude!, longitude: longitude!, name: name!, placeID: placeID!)
                    self.enableRatings()
                    
                    self.nearestVenueId = id!
                    print("NEAREST VENUE ID: \(self.nearestVenueId)")
                }
                
                // Load vibes
                ref.child("venues").child(id!).observeSingleEvent(of: .value, with: { (snapshot) in
                    let snapshotValue = snapshot.value as? NSDictionary
                    if let vibes = snapshotValue?["vibes"] as? [String: [String : AnyObject]] {
                        print("Found vibes for bar with place_id = \(id)!")
                        let number = vibes.count
                        var rating = 0
                        var invalids = 0
                        for (id, vibe) in vibes {
                            let vibeRating = vibe["rating"] as? Int
                            let vibeTimestamp = vibe["timestamp"] as! Double
                            if vibeTimestamp > (Date().timeIntervalSince1970 - 3600.0) {
                                print("Retrieved vibe ID #\(id): with rating \(vibeRating)")
                                rating = rating + vibeRating!
                            } else {
                                invalids = invalids + 1
                            }
                        }
                    
                        if (vibes.count - invalids) > 0 {
                            rating = rating / (vibes.count - invalids)
                        }
                    
                        let vibeObject: Vibe = Vibe(latitude: latitude!, longitude: longitude!, rating: rating)
                        vibeObject.number = number
                        self.vibes.append(vibeObject)
                    } else {
                        let vibeObject: Vibe = Vibe(latitude: latitude!, longitude: longitude!, rating: 0)
                        self.vibes.append(vibeObject)
                    }
                    self.plotVibes()
                })
            }
            
            self.loadingView.isHidden = true
        }
    }
    
    // MARK - Location Delegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        if let coordinate = location?.coordinate {
            self.mapView.setCenter(coordinate, animated: true)
        }
        
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("Starting monitoring \(region.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            print("Entering region")
            enableRatings()
            
            // Push notification to user
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            print("Exiting region")
            disableRatings()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Errors: " + error.localizedDescription)
    }
    
    func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        if self.vibes.count == 0 {
            self.loadDataJSON()
        }
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(_ mapView: MGLMapView, leftCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        return nil
    }
    
    func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        return UIButton(type: .detailDisclosure)
    }
    
    func mapView(_ mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
        self.selectedVenueName = annotation.title!!
        self.selectedVenueAddress = annotation.title!!
        self.selectedLatitude = annotation.coordinate.latitude
        self.selectedLongitude = annotation.coordinate.longitude
        self.selectedPlaceID = self.venueFromVibeCoordinates(annotation.coordinate.latitude, longitude: annotation.coordinate.longitude).placeID
        self.performSegue(withIdentifier: "showVenueDetails", sender: nil)
    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        // only concerned with point annotations.
        guard annotation is MGLPointAnnotation else {
            return nil
        }
        
        let pinIndex = getIndexOfVibe(annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        
        let pulsator = Pulsator()
        
        // Define pulse colors
        let redColor = UIColor(red:1.00, green:0.38, blue:0.38, alpha:1.0)
        let orangeColor = UIColor(red: 0.9765, green: 0.7647, blue: 0, alpha: 1.0)
        let greenColor = UIColor(red: 0.4235, green: 0.8784, blue: 0, alpha: 1.0)
        let blueColor = UIColor(red: 0, green: 0.7686, blue: 0.8863, alpha: 1.0)
        let purpleColor = UIColor(red: 0.4902, green: 0, blue: 0.8667, alpha: 1.0)
     
        let reuseIdentifier = "\(annotation.coordinate.longitude)"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            //annotationView = MGLAnnotationView(reuseIdentifier: reuseIdentifier)

            if pinIndex < self.vibes.count && pinIndex >= 0 {
                let vibe = self.vibes[pinIndex]
                
                // Add pulse to pin & set dimensions of pulse based on popularity of vibes
                pulsator.numPulse = self.vibes[pinIndex].number / 10 + 1
                pulsator.radius = 40.0
                
                if (vibe.rating == 1) {
                    // red for LIT
                    annotationView = MGLAnnotationView(reuseIdentifier: reuseIdentifier)
                    pulsator.backgroundColor = redColor.cgColor
                    annotationView!.layer.addSublayer(pulsator)
                    pulsator.start()
                } else if (vibe.rating == 2) {
                    // orange for POPPIN
                    annotationView = MGLAnnotationView(reuseIdentifier: reuseIdentifier)
                    pulsator.backgroundColor = orangeColor.cgColor
                    annotationView!.layer.addSublayer(pulsator)
                    pulsator.start()
                } else if (vibe.rating == 3) {
                    // green for OK
                    annotationView = MGLAnnotationView(reuseIdentifier: reuseIdentifier)
                    pulsator.backgroundColor = greenColor.cgColor
                    annotationView!.layer.addSublayer(pulsator)
                    pulsator.start()
                } else if (vibe.rating == 4) {
                    // blue for YIKES
                    annotationView = MGLAnnotationView(reuseIdentifier: reuseIdentifier)
                    pulsator.backgroundColor = blueColor.cgColor
                    annotationView!.layer.addSublayer(pulsator)
                    pulsator.start()
                } else if (vibe.rating == 5) {
                    // purple for SNOOZIN
                    annotationView = MGLAnnotationView(reuseIdentifier: reuseIdentifier)
                    pulsator.backgroundColor = purpleColor.cgColor
                    annotationView!.layer.addSublayer(pulsator)
                    pulsator.start()
                } else {
                    // nothin there = no visible pulse
                    //pulsator.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0).cgColor
                    
                    // Add marker
                    //annotationView = MGLAnnotationView(reuseIdentifier: "vibe")
                    //pulsator.backgroundColor = blueColor.cgColor
                }
                
                //pulsator.anchorPoint = CGPoint(x: annotationView!.frame.maxX, y: annotationView!.frame.maxY)
            }
        }
     
        return annotationView
    }
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        var annotationImage: MGLAnnotationImage? = mapView.dequeueReusableAnnotationImage(withIdentifier: "\(annotation.coordinate.longitude)")
        
        if annotationImage == nil {
            annotationImage = MGLAnnotationImage(image: UIImage(named: "VenueMarker")!, reuseIdentifier: "vibe")
        }
        
        return annotationImage
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        // LightContent
        return UIStatusBarStyle.lightContent
    }
    
    func plotVibes() {
        // Clear all annotations from map
        ///self.mapView.removeAnnotations(self.mapView.annotations) -- Mapbox replace implementation
        
        // Reload annotations
        print("Plotting vibes: \(self.vibes)")
        for i in 0..<self.vibes.count {
            // Add annotation to map
            let point = MGLPointAnnotation()
            point.coordinate = CLLocationCoordinate2D(latitude: Double(self.vibes[i].latitude), longitude: Double(self.vibes[i].longitude))
            point.title = self.venueFromVibeCoordinates(Double(self.vibes[i].latitude), longitude: Double(self.vibes[i].longitude)).name
            
            switch self.vibes[i].rating {
            case 1:
                point.subtitle = "This place is \"POPPIN'\" right now!"
            case 2:
                point.subtitle = "This place is \"pretty good\" right now."
            case 3:
                point.subtitle = "This place is \"alright\" right now."
            case 4:
                point.subtitle = "This place is \"slow\" right now."
            case 5:
                point.subtitle = "This place is \"dead\" right now."
            default:
                point.subtitle = "This place hasn't been rated yet."
            }
            
            self.mapView.addAnnotation(point)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVenueDetails" {
            let destinationViewController = segue.destination as! VenueDetailViewController
            destinationViewController.address = self.selectedVenueAddress
            destinationViewController.name = self.selectedVenueName
            destinationViewController.latitude = self.selectedLatitude
            destinationViewController.longitude = self.selectedLongitude
            destinationViewController.placeID = self.selectedPlaceID
        }
    }
    
    @IBAction func rate(_ sender: AnyObject) {
        FIRAnalytics.logEvent(withName: "Ratings", parameters: ["rating": sender.tag as NSObject])
        
        switch sender.tag {
        case 1:
            let uid = FIRAuth.auth()?.currentUser!.uid
            self.ref.child("venues").child(self.nearestVenueId).child("vibes").child(uid!).setValue(["rating": 1, "timestamp": Date().timeIntervalSince1970])
            
            resetButtons()
            self.vibeButton1.layer.opacity = 0.3
            self.navigationController!.navigationBar.barTintColor = UIColor(red:1.00, green:0.38, blue:0.38, alpha:1.0)
        case 2:
            let uid = FIRAuth.auth()?.currentUser!.uid
            self.ref.child("venues").child(self.nearestVenueId).child("vibes").child(uid!).setValue(["rating": 2, "timestamp": Date().timeIntervalSince1970])
            
            resetButtons()
            self.vibeButton2.layer.opacity = 0.3
            self.navigationController!.navigationBar.barTintColor = UIColor(red: 0.9765, green: 0.7647, blue: 0, alpha: 1.0)
        case 3:
            let uid = FIRAuth.auth()?.currentUser!.uid
            self.ref.child("venues").child(self.nearestVenueId).child("vibes").child(uid!).setValue(["rating": 3, "timestamp": Date().timeIntervalSince1970])
            
            resetButtons()
            self.vibeButton3.layer.opacity = 0.3
            self.navigationController!.navigationBar.barTintColor = UIColor(red: 0.4235, green: 0.8784, blue: 0, alpha: 1.0)
        case 4:
            let uid = FIRAuth.auth()?.currentUser!.uid
            self.ref.child("venues").child(self.nearestVenueId).child("vibes").child(uid!).setValue(["rating": 4, "timestamp": Date().timeIntervalSince1970])
            
            resetButtons()
            self.vibeButton4.layer.opacity = 0.3
            self.navigationController!.navigationBar.barTintColor = UIColor(red: 0, green: 0.7686, blue: 0.8863, alpha: 1.0)
        default:
            let uid = FIRAuth.auth()?.currentUser!.uid
            self.ref.child("venues").child(self.nearestVenueId).child("vibes").child(uid!).setValue(["rating": 5, "timestamp": Date().timeIntervalSince1970])
            
            resetButtons()
            self.vibeButton5.layer.opacity = 0.3
            self.navigationController!.navigationBar.barTintColor = UIColor(red: 0.4902, green: 0, blue: 0.8667, alpha: 1.0)
        }
    }
    
    @IBAction func refreshVibes(_ sender: AnyObject) {
        self.loadDataJSON() //self.loadData()
    }
    
    func resetButtons() {
        for button in [self.vibeButton1, self.vibeButton2, self.vibeButton3, self.vibeButton4, self.vibeButton5] {
            button?.layer.opacity = 1.0
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
            self.selectedLatitude = latitude
            self.selectedLongitude = longitude
        })
    }
    
    func setupAesthetics() {
        // Button setup
        for button in [self.vibeButton1, self.vibeButton2, self.vibeButton3, self.vibeButton4, self.vibeButton5] {
            button?.layer.borderWidth = 1.0
            button?.layer.masksToBounds = false
            button?.layer.cornerRadius = (button?.frame.size.width)! / 2.0
            
            print("Corner Radius: \(button?.layer.cornerRadius)")
            print("Button Width: \(button?.frame.size.width)")
            
            button?.clipsToBounds = true
        }
        
        self.vibeButton1.layer.borderColor = UIColor(red:1.00, green:0.38, blue:0.38, alpha:1.0).cgColor
        self.vibeButton2.layer.borderColor = UIColor(red: 0.9765, green: 0.7647, blue: 0, alpha: 1.0).cgColor
        self.vibeButton3.layer.borderColor = UIColor(red: 0.4235, green: 0.8784, blue: 0, alpha: 1.0).cgColor
        self.vibeButton4.layer.borderColor = UIColor(red: 0, green: 0.7686, blue: 0.8863, alpha: 1.0).cgColor
        self.vibeButton5.layer.borderColor = UIColor(red: 0.4902, green: 0, blue: 0.8667, alpha: 1.0).cgColor
        
        // Map center button setup
        self.mapCenterButton.layer.masksToBounds = false
        self.mapCenterButton.clipsToBounds = true
        self.mapCenterButton.layer.cornerRadius = 18
        self.mapCenterButton.layer.borderColor = UIColor(red: 0.345, green: 0.345, blue: 0.345, alpha: 1.0).cgColor
        
        // Loading view setup
        self.loadingView.layer.masksToBounds = false
        self.loadingView.clipsToBounds = true
        self.loadingView.layer.cornerRadius = 5
        self.activityIndicator.startAnimating() // and then just hide/show loadingView as needed
        
        let logo = UIImage(named: "BatLogoWhite")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
    }
    
    func showAlert(_ title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func venueFromVibeCoordinates(_ latitude: Double, longitude: Double) -> Venue {
        for venue in self.venues {
            if (venue.latitude == latitude && venue.longitude == longitude) {
                return venue
            }
        }
        return Venue(id: "ecoh", latitude: 0, longitude: 0, name: "none", placeID: "")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

