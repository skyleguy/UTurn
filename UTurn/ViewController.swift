//
//  ViewController.swift
//  UTurn
//
//  Created by Kyle Lobsinger on 9/22/16.
//  Copyright © 2016 L&C. All rights reserved.
//
//***********************FOR SOME REASON THE map IS NIL******************************

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!
    
    let locationManager = CLLocationManager()
    var mapp = MKMapView.self
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if (CLLocationManager.locationServicesEnabled())
        {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
            self.map.showsUserLocation = true
        }
        else
        {
            print("Location services are not enabled")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002))
        self.map.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Errors: " + error.localizedDescription)
    }
    
    func getDiectionFromGoogle(startCoordinate: CLLocationCoordinate2D, toLocation: CLLocationCoordinate2D) {
        var urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(startCoordinate.latitude),\(startCoordinate.longitude)&destination=\(toLocation.latitude),\(toLocation.longitude)&key=\("AIzaSyAcWtZFqgPfMNTQccPC0a30PBALDtYNtAk")"
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let session = URLSession.shared
        let placesTask = session.dataTask(with: URL(string: urlString)!, completionHandler: {data, response, error in
            if error != nil {
            }
            if ((try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSDictionary) != nil {
                
            }
        })
        placesTask.resume()
    }
}

