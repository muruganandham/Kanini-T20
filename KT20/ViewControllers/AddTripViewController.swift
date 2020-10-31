//
//  AddTripViewController.swift
//  KT20
//
//  Created by Muruganandham on 31/10/20.
//

import UIKit

class AddTripViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton! {
        didSet {
            startButton.layer.cornerRadius = startButton.frame.size.height / 2.0
        }
    }
    
    @IBOutlet weak var stopButton: UIButton! {
        didSet {
            stopButton.layer.cornerRadius = stopButton.frame.size.height / 2.0
        }
    }
    
    @IBOutlet weak var addSpotButton: UIButton! {
        didSet {
            addSpotButton.layer.cornerRadius = addSpotButton.frame.size.height / 2.0
        }
    }
    
    var isStarted: Bool = false {
        didSet {
            if isStarted {
                startButton.isHidden = true
                addSpotButton.isHidden = false
                stopButton.isHidden = false
            } else {
                startButton.isHidden = false
                addSpotButton.isHidden = true
                stopButton.isHidden = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isStarted = false
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        
        if isStarted {
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        isStarted = true
        LocationManager.shared.getUserLocation { (location) in
            SharedObjects.shared.activeTrip?.startTime = "\(Date())"
            SharedObjects.shared.activeTrip?.sourceLat = "\(location?.coordinate.latitude)"
            SharedObjects.shared.activeTrip?.sourceLong = "\(location?.coordinate.longitude)"
            SharedObjects.shared.activeTrip?.tripId = UUID().uuidString.lowercased()
            SharedObjects.shared.activeTrip?.routeArray = ["\(location?.coordinate.latitude), \(location?.coordinate.longitude)"]
            location?.coordinate.lookupPlacemark(completionHandler: { (placemark) in
                if let placemark = placemark, !placemark.fullAddress.isEmpty {
                    SharedObjects.shared.activeTrip?.sourceAddress = placemark.fullAddress
                }
            })
        }
    }
    
    @IBAction func stopButtonPressed(_ sender: Any) {
        isStarted = false
        LocationManager.shared.getUserLocation { (location) in
            SharedObjects.shared.activeTrip?.endTime = "\(Date())"
            SharedObjects.shared.activeTrip?.destinationLat = "\(location?.coordinate.latitude)"
            SharedObjects.shared.activeTrip?.destinationLong = "\(location?.coordinate.longitude)"
            SharedObjects.shared.activeTrip?.routeArray.append("\(location?.coordinate.latitude), \(location?.coordinate.longitude)")
            location?.coordinate.lookupPlacemark(completionHandler: { (placemark) in
                if let placemark = placemark, !placemark.fullAddress.isEmpty {
                    SharedObjects.shared.activeTrip?.destinationAddress = placemark.fullAddress
                }
                
                //final
                let trip = SharedObjects.shared.activeTrip
                print(trip?.startTime)
                print(trip?.sourceAddress)
                print(trip?.endTime)
                print(trip?.destinationAddress)
                print(trip?.routeArray)
            })
        }
    }
    
    @IBAction func addStopButtonPressed(_ sender: Any) {
    

    }
}
