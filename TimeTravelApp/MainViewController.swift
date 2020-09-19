//
//  MainViewController.swift
//  TimeTravelApp
//
//  Created by Srivalli Kanchibotla on 9/14/19.
//  Copyright © 2019 Srivalli Kanchibotla. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MainViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var vstackView: UIStackView!
    
    
    let locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 1000
    let didPreloadDataKey = "didPreloadData"
    
    var yearPickerView = UIPickerView()
    var yearPickerData: [Int] = []
    
    var latitudeTextField = UITextField()
    var longitudeTextField = UITextField()
    var yearPickerField = UITextField()
    
    public static var nearestTwentyEvents: [NobelPrizeLaureates] = []
    public var nobelPrizeLaureates: [NobelPrizeLaureates] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //to request location permissions
        self.locationManager.requestWhenInUseAuthorization()
        
        setInputFields()
        
        yearPickerView.backgroundColor = .white
        yearPickerView.delegate = self
        yearPickerView.dataSource = self
        yearPickerField.inputView = yearPickerView
        
        mapView.delegate = self
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        if !UserDefaults.standard.bool(forKey: didPreloadDataKey) {
            NobelPrizeDataParser.shared.setCoreDataContents()
            UserDefaults.standard.set(true, forKey: didPreloadDataKey)
        }
        
        centerMapOnLocation()
        
        //creating year picker data
        for year in 1900...2020 {
            yearPickerData.append(year)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setInputFields () {
        let latitudeLabel = UILabel(frame: CGRect(x: vstackView.frame.minX, y: vstackView.frame.minY, width: 20, height: 10))
        latitudeLabel.text = "Latitude :"
        latitudeLabel.textAlignment = .center
        
        let longitudeLabel = UILabel(frame: CGRect(x: vstackView.frame.minX, y: vstackView.frame.minY, width: 20, height: 10))
        longitudeLabel.text = "Logitude : "
        longitudeLabel.textAlignment = .center
        
        let yearLabel = UILabel(frame: CGRect(x: vstackView.frame.minX, y: vstackView.frame.minY, width: 20, height: 10))
        yearLabel.text = "Year : "
        yearLabel.textAlignment = .center
        
        latitudeTextField = UITextField(frame: CGRect(x: vstackView.frame.minX , y: vstackView.frame.minY + 25, width: 20, height: 10))
        latitudeTextField.keyboardType = .numberPad
        
        longitudeTextField = UITextField(frame: CGRect(x: vstackView.frame.minX , y: vstackView.frame.minY + 25, width: 20, height: 10))
        longitudeTextField.keyboardType = .numberPad
        
        yearPickerField = UITextField(frame: CGRect(x: vstackView.frame.minX , y: vstackView.frame.minY + 25, width: 20, height: 10))
        yearPickerField.inputView = yearPickerView

        vstackView.addSubview(latitudeLabel)
        vstackView.addSubview(latitudeTextField)
        vstackView.addSubview(longitudeLabel)
        vstackView.addSubview(longitudeTextField)
        vstackView.addSubview(yearLabel)
        vstackView.addSubview(yearPickerField)
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.view == self.view {
            yearPickerField.endEditing(true)
        }
    }
    
    private func latLongTextFieldValidation() -> [CLLocationDegrees] {
        var coordinates: [CLLocationDegrees] = []
        if let latText = latitudeTextField.text, let longText = longitudeTextField.text, let lat = CLLocationDegrees(latText), let long = CLLocationDegrees(longText) {
            if lat >= -90 && lat <= 90 && long >= -180 && long <= 180 { //validating latitude and longitude
                coordinates = [lat, long]
            }
        }
        return coordinates
    }
    
    @IBAction func getClosestLocations(_ sender: Any) {
        
        //year
        var currentYear = Calendar.current.component(.year, from: Date())
        if let yearText = yearPickerField.text {      //when user did not enter year in the fields, fall back is to use current year
            currentYear = Int(yearText) ?? currentYear
        }
        //location
        var currentLocation: [CLLocationDegrees] = []
        let manualLocation = latLongTextFieldValidation()
        if manualLocation.isEmpty {     //when user did not enter location in the fields, fall back is to use device's location
            if let location = locationManager.location?.coordinate {
                currentLocation = [location.latitude, location.longitude]
            } else {
                let alertController = UIAlertController(title: "Location Permissions", message: "Please enter a value in Latitude & Longitude fiels.\nOR\n Go to Settings and change location permissions for Time Travel", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
        } else {    //when user entered valid location in text fields
            currentLocation = manualLocation
        }
        
        MainViewController.nearestTwentyEvents = getTwentyClosestLocation(currentLocation , currentYear)
        
    }
    
    // To zoom in and center map on the current location
    func centerMapOnLocation() {
        
        guard let location = locationManager.location else { return }
        
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    func getTwentyClosestLocation(_ coordinates: [Double], _ currentYear: Int) -> [NobelPrizeLaureates] {
        
        self.nobelPrizeLaureates.removeAll()
        
        self.nobelPrizeLaureates.append(contentsOf: NobelPrizeDataParser.shared.getCoreDataContents())
        
        var closestTwentyEvents: [NobelPrizeLaureates] = []
        var travelCost: [Int: Double] = [:]
        let currentLocation = CLLocation(latitude: coordinates.first!, longitude: coordinates.last!)
        
        for nobelPrizeData in self.nobelPrizeLaureates {
            
            let nobelPrizeLocation = CLLocation(latitude: nobelPrizeData.latitude, longitude: nobelPrizeData.longitude)
            var travelDistanceCost = currentLocation.distance(from: nobelPrizeLocation)/10000 //Divide by 1000 to get distance in kms. Divide by 10 to get 1 unit of travel cost
            travelDistanceCost = travelDistanceCost + Double(abs(currentYear - nobelPrizeData.year))
            travelCost.updateValue(travelDistanceCost, forKey: nobelPrizeData.id)
        }
        //sort by ascending order
        let travelCostSorted = travelCost.sorted { $0.value < $1.value }
        let resultList = Array(travelCostSorted).prefix(upTo: 20)
        
        for result in resultList {
            let data = self.nobelPrizeLaureates.filter({$0.id == result.key})
            if !data.isEmpty {
                closestTwentyEvents.append(data.first!)
            }
        }
        return closestTwentyEvents
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return yearPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(yearPickerData[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        yearPickerField.text = String(yearPickerData[row])
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
