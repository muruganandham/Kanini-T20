//
//  AddTripViewController.swift
//  KT20
//
//  Created by Muruganandham on 31/10/20.
//

import UIKit
import Firebase
import CoreLocation

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
    
    var currentTripId: String!
    var dbRef: DatabaseReference {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        return ref
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
                if let trip = SharedObjects.shared.activeTrip, let tripId = self.startTrip(trip: trip) {
                    print(tripId)
                    LocationManager.shared.delegate = self
                    self.currentTripId = tripId
                }
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
        })
    }
    
    @IBAction func addStopButtonPressed(_ sender: Any) {
    

    }
    
    //MARK: - Methods
    fileprivate func startTrip(trip: Trip) -> String? {
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
                               "startedAt": "\(trip.startTime)",
                               "endedAt": "\(trip.endTime)",
                               "kms": 5.0])
            return tripsRef.key
        }
        return nil
    }
}

extension AddTripViewController: LocationManagerDelegate {
    func didFailWithError(error: Error) {
        print(error.localizedDescription)
    }
    
    func didUpdateLocation(location: CLLocation) {
        print(location)
        let spotsRef = dbRef.child("spots").child(currentTripId).childByAutoId()
        spotsRef.setValue(["lat": location.coordinate.latitude,
                           "lng":location.coordinate.longitude])
    }
}
