//
//  Venue.swift
//  ecoh
//
//  Created by Ryan Chiu on 7/26/16.
//  Copyright © 2016 Ecoh Technologies, LLC. All rights reserved.
//

import Foundation

class Venue: NSObject {
    var id: String
    var latitude: Double
    var longitude: Double
    var name: String
    var placeID: String
    
    init(id: String, latitude: Double, longitude: Double, name: String, placeID: String) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.placeID = placeID
    }
    
    convenience override init() {
        self.init(id: "ecoh", latitude: 0, longitude: 0, name: "Venue", placeID: "")
    }
}
