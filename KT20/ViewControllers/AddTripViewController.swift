//
//  AddTripViewController.swift
//  KT20
//
//  Created by Muruganandham on 31/10/20.
//

import UIKit
import Firebase

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
        LocationManager.shared.startLocation()
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        if isStarted {
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        isStarted = true
        guard let location = LocationManager.shared.userLocation else {
            return
        }
        SharedObjects.shared.activeTrip = Trip()
        SharedObjects.shared.activeTrip?.startTime = "\(Date())"
        SharedObjects.shared.activeTrip?.sourceLat = "\(location.coordinate.latitude)"
        SharedObjects.shared.activeTrip?.sourceLong = "\(location.coordinate.longitude)"
        SharedObjects.shared.activeTrip?.tripId = UUID().uuidString.lowercased()
        SharedObjects.shared.activeTrip?.routeArray = ["\(location.coordinate.latitude), \(location.coordinate.longitude)"]
        location.coordinate.lookupPlacemark(completionHandler: { (placemark) in
            if let placemark = placemark, !placemark.fullAddress.isEmpty {
                SharedObjects.shared.activeTrip?.sourceAddress = placemark.fullAddress
            }
        })
    }
    
    @IBAction func stopButtonPressed(_ sender: Any) {
        isStarted = false
        guard let location = LocationManager.shared.userLocation else {
            return
        }
        SharedObjects.shared.activeTrip?.endTime = "\(Date())"
        SharedObjects.shared.activeTrip?.destinationLat = "\(location.coordinate.latitude)"
        SharedObjects.shared.activeTrip?.destinationLong = "\(location.coordinate.longitude)"
        SharedObjects.shared.activeTrip?.routeArray?.append("\(location.coordinate.latitude), \(location.coordinate.longitude)")
        location.coordinate.lookupPlacemark(completionHandler: { (placemark) in
            if let placemark = placemark, !placemark.fullAddress.isEmpty {
                SharedObjects.shared.activeTrip?.destinationAddress = placemark.fullAddress
                LocationManager.shared.stopLocation()
            }
            
            //final
            print(SharedObjects.shared.activeTrip)
            if let trip = SharedObjects.shared.activeTrip {
                print(trip)
                self.startTrip(trip: trip)
            }
        })
    }
    
    @IBAction func addStopButtonPressed(_ sender: Any) {
    

    }
    
    //MARK: - Methods
    
    fileprivate func startTrip(trip: Trip) {
        if let userId = UserManager.shared.userId, trip != nil {
            var ref: DatabaseReference!
            ref = Database.database().reference()
            let tripsRef = ref.child("trips").child(userId).childByAutoId()
            tripsRef.setValue(["title":"New trip",
                               "sourceAddress": trip.sourceAddress,
                               "destinationAddress": trip.destinationAddress,
                               "sourceLat": trip.sourceLat,
                               "sourceLong": trip.sourceLong,
                               "destinationLat": trip.destinationLat,
                               "destinationLong": trip.destinationLong,
                               "startedAt": trip.startTime,
                               "endedAt": trip.endTime,
                               "kms": 5.0])
        }
    }
}
