//
//  TravelView.swift
//  ecoh
//
//  Created by Ryan Chiu on 5/30/16.
//  Copyright © 2016 Ecoh Technologies, LLC. All rights reserved.
//

import UIKit
import CoreLocation
import AddressBook
import MapKit


class TravelView : UIView {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressTitleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var directionsButton: UIButton!
    
    var coords: CLLocationCoordinate2D? // for converting raw text address back to geocoords
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "TravelView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! UIView
    }
    
    // When user pushes the "Get Directions" button on the app
    @IBAction func getDirections(sender: AnyObject) {
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(addressLabel.text!, completionHandler:
            {(placemarks: [CLPlacemark]?, error: NSError?) in
                
                if error != nil {
                    print("Geocode failed with error: \(error!.localizedDescription)")
                } else if placemarks!.count > 0 {
                    let placemark = placemarks![0] as CLPlacemark
                    let location = placemark.location
                    self.coords = location!.coordinate
                    
                    // Get directions to address via Apple Maps
                    self.showMap()
                }
        })
    }
    
    // Get directions to address via Apple Maps
    func showMap() {
        let addressDict = [kABPersonAddressStreetKey as String: addressLabel.text!]
        let place = MKPlacemark(coordinate: coords!, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: place)
        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMapsWithLaunchOptions(options)
    }
}


