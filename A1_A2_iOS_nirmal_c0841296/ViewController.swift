//
//  ViewController.swift
//  A1_A2_iOS_nirmal_c0841296
//
//  Created by nirmal on 2022-05-24.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    // created location manager instance
    var locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestLocationAccessAuthorization()
        // Do any additional setup after loading the view.
    }

    public func requestLocationAccessAuthorization () {
        self.locationManager.delegate = self
        let currentStatus = CLLocationManager.authorizationStatus()
        
        // only proceed below to ask for permission if the status is not determined
        guard currentStatus ==  .notDetermined else {return}
        
        self.locationManager.requestWhenInUseAuthorization()
    }
}

