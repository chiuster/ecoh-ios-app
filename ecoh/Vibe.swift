//
//  Vibe.swift
//  ecoh
//
//  Created by Ryan Chiu on 6/4/16.
//  Copyright © 2016 Ecoh Technologies, LLC. All rights reserved.
//

import Foundation

class Vibe: NSObject {
    var latitude: Double
    var longitude: Double
    var rating: Int
    
    var number: Int
    
    init(latitude: Double, longitude: Double, rating: Int) {
        self.latitude = latitude
        self.longitude = longitude
        self.rating = rating
        self.number = 1
    }
    
    convenience override init() {
        self.init(latitude: 0, longitude: 0, rating: 1)
    }
}
