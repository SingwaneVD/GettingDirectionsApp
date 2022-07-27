//
//  ViewController.swift
//  GettingDirectionsApp
//
//  Created by IACD-024SingwaneVD on 2022/07/27.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate ,MKMapViewDelegate{

    @IBOutlet var enterAddressTF: UITextField!
    @IBOutlet var fetchDirectionsBTN: UIButton!
    @IBOutlet var mapViewMV: MKMapView!
    
    var locationManager = CLLocationManager()   //managing the user's location
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // requesting authorization
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        map.delegate = self
        
        
    }
    @IBAction func fetchDirectionsTapped(_ sender: Any) {
        getAddress()
    }
    
    func getAddress(){
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(enterAddressTF.text!) {(placemarks, error) in
        guard let placemarks = placemarks, let location =
                placemarks.first?.location
            else{
                print("Location Not Found")
                return
            }
            print(location)
            
            self.mapThis(destinationCord: location.coordinate)
    }
}

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
    }
    
    func mapThis(destinationCord: CLLocationCoordinate2D){
        let sourceCoordinate = (locationManager.location?.coordinate)!
        
        let sourcePlaceMark = MKPlacemark(coordinate: sourceCoordinate)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationCord)
        //making mapkit items for the coordinates
        let sourceItem = MKMapItem(placemark: sourcePlaceMark)
        let destItem = MKMapItem(placemark: destinationPlaceMark)
        //making a request from Apple to get the destination route
        let destinationRequest = MKDirections.Request()
        destinationRequest.source = sourceItem  //where we want to start
        destinationRequest.destination = destItem  // where we are going
        
        destinationRequest.transportType = .automobile  //type of transport type
        destinationRequest.requestsAlternateRoutes = true // getting multiple routes or just one
        
        
        let directions = MKDirections(request: destinationRequest)
        directions.calculate {( response, error) in
            guard let response = response else{
            if let error = error {
                print("Something is wrong: (")
            }
            return
        }
        
            
            let route = response.routes[0]
            self.map.addOverlay(route.polyline) //Check for error and updates or the current version
            self.map.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
        
    }
}
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolygonRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = .green // color of the navigation line or route line
    
        return render
    }
}
