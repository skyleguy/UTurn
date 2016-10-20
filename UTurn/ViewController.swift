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
import GoogleMaps
import GooglePlaces
import CoreLocation


class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var latField: UITextField!
    @IBOutlet weak var longField: UITextField!
    
    var keyy = "AIzaSyBqm3VZ-er33Z6Pp6FI0d9KtKIBLpxcNjs"
    var currLocation: CLLocationCoordinate2D!
    let locationManager = CLLocationManager()
    var mapp = MKMapView.self
    var toLocation: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if (CLLocationManager.locationServicesEnabled())
        {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestWhenInUseAuthorization()
            self.map.setUserTrackingMode(.follow, animated: true)
            self.map.showsUserLocation = true
            self.locationManager.startUpdatingLocation()
            self.locationManager.distanceFilter = 10
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
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        self.map.showsUserLocation = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last
        currLocation = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002))
        self.map.setRegion(region, animated: true)
        //self.locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Errors: " + error.localizedDescription)
    }
    
    func getDirectionFromGoogle(startCoordinate: CLLocationCoordinate2D, toLocation: CLLocationCoordinate2D) {
        var urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(startCoordinate.latitude),\(startCoordinate.longitude)&destination=\(toLocation.latitude),\(toLocation.longitude)&key=\(keyy)"
        print(urlString)
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let session = URLSession.shared
        let placesTask = session.dataTask(with: URL(string: urlString)!, completionHandler: {data, response, error in
            if error != nil {
            }
            if let jsonResult = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSDictionary
            {
                print("JSON result: \(jsonResult)")
                if let routes = jsonResult["routes"] as? NSArray
                {
                    if let legs = routes.value(forKey: "legs") as? NSArray
                    {
                        if let steps = legs.value(forKey: "steps") as? NSArray
                        {
                            if steps.count != 0
                            {
                                if let firstStep = steps.object(at: 0) as? NSArray
                                {
                                    if firstStep.count != 0
                                    {
                                        if let paths = firstStep.object(at: 0) as? NSArray
                                        {
                                            if paths.count > 0
                                            {
                                                for i in 0 ..< paths.count
                                                {
                                                    if let polyline = (paths[i] as AnyObject).value(forKey: "polyline") as? NSDictionary {
                                                        if let points = polyline.value(forKey: "points") as? String {
                                                            let gmsPath = GMSPath(fromEncodedPath: points)
                                                            for index in 0 ..< gmsPath!.count() {
                                                                let coordinate = gmsPath!.coordinate(at: index)
                                                                //self.polylineCoordinates.append(coordinate)
                                                                //self.path.add(coordinate)
                                                                let path = GMSMutablePath()
                                                                path.add(coordinate)
                                                                let polyline = GMSPolyline(path: path)
                                                                polyline.map = map
                                                                print("coordinate \(index): \(coordinate)")
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
        placesTask.resume()
        self.locationManager.stopUpdatingLocation()
    }
    
    @IBAction func buttonPressed(_ sender: AnyObject) {
        var title = ""
        var title2 = ""
        if self.latField.text! == "" || self.longField.text! == ""
        {
            title = title + "Invalid Place"
            title2 = title2 + "You need to enter a valid place!"
        }
        else
        {
            title = title + "Confirm Place"
            title2 = title2 + "You want to go from your location to \(self.latField.text!), \(self.longField.text!)?"
        }
        let controller = UIAlertController(title: title, message: title2, preferredStyle: .actionSheet)
        let yesAction = UIAlertAction(title: "Yes", style: .destructive, handler: { action in
            self.toLocation = CLLocationCoordinate2D(latitude: (self.latField.text! as NSString).doubleValue, longitude: (self.longField.text! as NSString).doubleValue)
            self.getDirectionFromGoogle(startCoordinate: self.currLocation, toLocation: self.toLocation)
        })
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        controller.addAction(yesAction)
        controller.addAction(noAction)
        if let ppc = controller.popoverPresentationController {
            ppc.sourceView = sender as? UIView
            ppc.sourceRect = sender.bounds
        }
        self.latField.resignFirstResponder()
        self.longField.resignFirstResponder()
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func centerScreen(_ sender: AnyObject)
    {
        let center = CLLocationCoordinate2D(latitude: currLocation.latitude, longitude: currLocation.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002))
        self.map.setRegion(region, animated: true)
    }
    
    @IBAction func getRidOfKeyboard(_ sender: AnyObject)
    {
        self.latField.resignFirstResponder()
        self.longField.resignFirstResponder()
    }
}

