//
//  ViewController.swift
//  A1_A2_iOS_nirmal_c0841296
//
//  Created by nirmal on 2022-05-24.
//

import UIKit
import MapKit
import GLKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    // created location manager instance
    var locationManager: CLLocationManager = CLLocationManager()
    // initialize place variable
    var places: [Place] = [Place]()
    // user location
    var currentUserLocation: CLLocationCoordinate2D? = nil
    
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
        
        // if the user has already granted permission return
        guard currentStatus ==  .notDetermined else {return}
        
        // ask for the user permission
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // check if the location is available
        if let location = locations.last {
            currentUserLocation = location.coordinate
            
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
                drawRoute()
                break
            
            default:
                // remove annotations and overlays
                removeAnnotations()
                removeOverlays()
        
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
        // set the tap frequency to 2
        tapGestureRecognizer.numberOfTapsRequired = 2
        
        // add the tap gesture recognizer
        self.mapView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func addTriangle() {
        // make coordinates array
        let coordinates = places.map {$0.coordinate}
        // make a polygon
        let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
        
        self.mapView.addOverlay(polygon)
    }
    
    func removeAnnotations () {
        // remove annotations from map
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
    func removeOverlays () {
        // remove overlays from map
        for overlay in mapView.overlays {
            mapView.removeOverlay(overlay)
        }
    }
    
    public func calculateDistanceBetweenUserAndMarker (markerLocation: CLLocationCoordinate2D) -> Double {
        var distance: Double = 0
        
        if let uLocation = currentUserLocation {
            // create current user location
            let currentUserLocation = CLLocation(latitude: uLocation.latitude, longitude: uLocation.longitude)
            
            // calculate distance from current user location
            distance = currentUserLocation.distance(from: CLLocation(latitude: markerLocation.latitude, longitude: markerLocation.longitude))
        }
        
        return distance
    }
    
    public func drawRoute () {
        drawRouteBetweenMarkers(source: places[0].coordinate, destination: places[1].coordinate)
        drawRouteBetweenMarkers(source: places[1].coordinate, destination: places[2].coordinate)
        drawRouteBetweenMarkers(source: places[2].coordinate, destination: places[0].coordinate)
    }
    
    public func drawRouteBetweenMarkers (source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        if self.places.count < 3 {
            return
        }
        
        removeOverlays()
        
        let sourcePlaceMark = MKPlacemark(coordinate: source)
        let destinationPlaceMark = MKPlacemark(coordinate: destination)
        
        // request a direction
        let directionRequest = MKDirections.Request()
        
        // assign the source and destination properties of the request
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        
        // transportation type
        directionRequest.transportType = .walking
        
        // calculate the direction
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let directionResponse = response else {return}
            // create the route
            let route = directionResponse.routes[0]
            // drawing a polyline
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            
            // define the bounding map rect
            let rect = route.polyline.boundingMapRect
            self.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
            
//            self.map.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
}

extension ViewController: MKMapViewDelegate {
    // for displaying annotation
    

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
        } else if overlay is MKPolyline {
            let rendrer = MKPolylineRenderer(overlay: overlay)
            rendrer.strokeColor = UIColor.blue
            rendrer.lineWidth = 3
            return rendrer
        }
        
        return MKOverlayRenderer()
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation.title {
            case "A", "B", "C":
                let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "markerPin")
                annotationView.canShowCallout = true
                annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                return annotationView
            default:
                return nil
        }
    }
    
    // function to display detail view
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // get the view annotation
        if let annotation = view.annotation {
            let markerLocation = annotation.coordinate
            
            // calling function to calculate the distance
            let distance = calculateDistanceBetweenUserAndMarker(markerLocation: markerLocation)
            
            displayAnnotationAlert (distance: distance)
        }
    }
    
    // function to display annotation to the user
    public func displayAnnotationAlert (distance: Double) {
        // display the distance between the user and the marker
        let message = String(format: "The distance from this point to user's location is %.2f", distance)
        
        let alertController = UIAlertController(title: "Distance between user and point", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}
