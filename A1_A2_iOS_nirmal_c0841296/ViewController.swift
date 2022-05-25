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
        
        // start getting the user location
        self.locationManager.startUpdatingLocation()
        
        // double tap gesture initialization
        addDoubleTapGestureRecognizer()

        self.mapView.delegate = self
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
        let doubleTapPoint = userGestureRecognizer.location(in: self.mapView)
        let doubleTapCoordinate = self.mapView.convert(doubleTapPoint, toCoordinateFrom: self.mapView)
        let placesCount = self.places.count
        var title: String = ""
        
        switch placesCount {
            case 0:
                title = "A"
                self.places.append(Place(title: title, coordinate: doubleTapCoordinate))
                break
            
            case 1:
                title = "B"
                self.places.append(Place(title: title, coordinate: doubleTapCoordinate))
                break

            case 2:
                title = "C"
                self.places.append(Place(title: title, coordinate: doubleTapCoordinate))
                
                addTriangle()
                break
            
            default:
                // remove annotations and overlays
                removeAnnotationsAndOverlays()
        
                self.places = [Place]()
                // remove annotations and overlays and return
                return
        }
        
        // create tap annotation
        let tapAnnotation = MKPointAnnotation()
        // set the coordinate
        tapAnnotation.coordinate = doubleTapCoordinate
        // set the title
        tapAnnotation.title = title
        
        // add annotation on map
        self.mapView.addAnnotation(tapAnnotation)
    }
    
    public func addDoubleTapGestureRecognizer () {
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addTapGestureRecognizerAnnotation))
        tapGestureRecognizer.numberOfTapsRequired = 2
        
        self.mapView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func addTriangle() {
        // make coordinates array
        let coordinates = places.map {$0.coordinate}
        // make a polygon
        let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
        
        self.mapView.addOverlay(polygon)
    }
    
    func removeAnnotationsAndOverlays () {
        // remove annotations from map
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
        
        // remove overlays from map
        for overlay in mapView.overlays {
            mapView.removeOverlay(overlay)
        }
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolygon {
            let rendrer = MKPolygonRenderer(overlay: overlay)
            // fill the area by red color with 50% transparancy
            rendrer.fillColor = UIColor.red.withAlphaComponent(0.5)
            // set the color to green
            rendrer.strokeColor = UIColor.green
            // set the line width to 2
            rendrer.lineWidth = 2
            return rendrer
        }
        return MKOverlayRenderer()
    }
}
