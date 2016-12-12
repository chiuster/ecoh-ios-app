//
//  MapData.swift
//  ecoh
//
//  Created by Ryan Chiu on 9/1/16.
//  Copyright © 2016 Ecoh Technologies, LLC. All rights reserved.
//

import Foundation

class MapData: NSObject {
    
    var vibes: [Vibe]
    var venues: [Venue]
    
    init(vibes: [Vibe], venues: [Venue]) {
        self.vibes = vibes
        self.venues = venues
    }
    
    func venueFromVibeCoordinates(_ latitude: Double, longitude: Double) -> Venue {
        for venue in self.venues {
            if (venue.latitude == latitude && venue.longitude == longitude) {
                return venue
            }
        }
        return Venue(id: "", latitude: 0, longitude: 0, name: "none", placeID: "")
    }
}
