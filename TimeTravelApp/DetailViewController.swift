//
//  DetailViewController.swift
//  TimeTravelApp
//
//  Created by Srivalli Kanchibotla on 9/15/19.
//  Copyright © 2019 Srivalli Kanchibotla. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class DetailViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var detailMapView: MKMapView!
    @IBOutlet weak var detailTextView: UITextView?
    
    var detailMapViewLocation: CLLocationCoordinate2D?
    var detailTextViewText: String?
    
    let locationManager = CLLocationManager()
    var detailLocationPin = MKPointAnnotation()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        detailMapView.delegate = self
        detailMapView.showsUserLocation = true
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        if let _ = detailTextViewText {
            detailTextView?.text = detailTextViewText
        }
        
        if let detailLocation = detailMapViewLocation {
            
            detailLocationPin.coordinate = detailLocation
            detailMapView.addAnnotation(detailLocationPin)
            detailMapView.setRegion(MKCoordinateRegion(center: detailLocation, latitudinalMeters: 1000, longitudinalMeters: 1000), animated: true)
        }
        
    }
}
