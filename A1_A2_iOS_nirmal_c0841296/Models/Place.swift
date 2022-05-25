//
//  Place.swift
//  A1_A2_iOS_nirmal_c0841296
//
//  Created by nirmal on 2022-05-24.
//

import Foundation
import MapKit

class Place: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }
}
