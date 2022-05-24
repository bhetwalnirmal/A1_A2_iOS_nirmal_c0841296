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
    // initialize place variable
    var places: [Place] = [Place]()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // function to setup location authorization
        requestLocationAccessAuthorization()
    }

    public func requestLocationAccessAuthorization () {
        self.locationManager.delegate = self
        // disable zoom when user double taps
        self.mapView.isZoomEnabled = false
        
        // setting the desired accuracy of the location to best accuracy
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        let currentStatus = CLLocationManager.authorizationStatus()
        
        // only proceed below to ask for permission if the status is not determined
        guard currentStatus ==  .notDetermined else {return}
        
        // ask for the user permission
        self.locationManager.requestWhenInUseAuthorization()
        
        // start getting the user location
        self.locationManager.startUpdatingLocation()
        
        // long press gesture initialization
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addTapGestureRecognizerAnnotation))
        tapGestureRecognizer.numberOfTapsRequired = 2
        
        self.mapView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // check if the location is available
        if let location = locations.last {
            displayUserCurrentLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, title: "You are here!")
        }
    }
    
    public func displayUserCurrentLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees, title: String) {
        let latitudeDelta: CLLocationDegrees = 0.05
        let longitudeDelta: CLLocationDegrees = 0.05
        let location = CLLocationCoordinate2DMake(latitude, longitude)
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        let region = MKCoordinateRegion(center: location, span: span)
        
        self.mapView.region = region
        
        // function to display annotation
        displayAnnotationOnUserCurrentLocation(location: location)
    }
    
    public func displayAnnotationOnUserCurrentLocation (location: CLLocationCoordinate2D) {
        let annotation: MKPointAnnotation = MKPointAnnotation()
        // set the annotation coordinate same as the user's location
        annotation.coordinate = location
        // set the title of the annotation
        annotation.title = "You are Here!"
        // attach and display the annotation in the map
        self.mapView.addAnnotation(annotation)
    }
    
    // add annotation to gesture recognizer
    @objc public func addTapGestureRecognizerAnnotation (userGestureRecognizer: UIGestureRecognizer) {
        let longPressPoint = userGestureRecognizer.location(in: self.mapView)
        let longPressCoordinate = self.mapView.convert(longPressPoint, toCoordinateFrom: self.mapView)
        let placesCount = self.places.count
        var title: String = ""
        
        switch placesCount {
            case 0:
                title = "A"
                break
            
            case 1:
                title = "B"
                break

            case 2:
                title = "C"
                break
            
            default:
                break
        }
        
        let place: Place = Place(title: title, coordinate: longPressCoordinate)
        self.places.append(place)
        print(self.places.count)
        let longPressAnnotation = MKPointAnnotation()
        longPressAnnotation.coordinate = longPressCoordinate
        longPressAnnotation.title = title
        
        self.mapView.addAnnotation(longPressAnnotation)
    }
}

