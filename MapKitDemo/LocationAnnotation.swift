//
//  LocationAnnotation.swift
//  MapKitDemo
//
//  Created by RTC-HN154 on 11/8/19.
//  Copyright © 2019 RTC-HN154. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class LocationAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    init (coordinate: CLLocationCoordinate2D, title: String) {
        self.coordinate = coordinate
        self.title = title
    }
}
