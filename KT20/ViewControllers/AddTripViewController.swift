//
//  AddTripViewController.swift
//  KT20
//
//  Created by Muruganandham on 31/10/20.
//

import UIKit
import Firebase
import CoreLocation
import MapKit

class AddTripViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.mapType = MKMapType.standard
            mapView.isZoomEnabled = true
            mapView.isScrollEnabled = true
            mapView.delegate = self
            mapView.userTrackingMode = .followWithHeading
            mapView.showsUserLocation = true
        }
    }
    
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
    var currentSpotkey: String?
    var currentLocation: CLLocation!
    var points = [CLLocationCoordinate2D]()
    var didClose: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isStarted = false
        LocationManager.shared.startLocation()
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        if isStarted {
        } else {
            if let close = self.didClose {
                close()
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        isStarted = true
        guard let location = LocationManager.shared.userLocation else {
            return
        }
        SharedObjects.shared.activeTrip = Trip()
        SharedObjects.shared.activeTrip?.startedAt = Date().timeIntervalSinceReferenceDate
        SharedObjects.shared.activeTrip?.sourceLat = location.coordinate.latitude
        SharedObjects.shared.activeTrip?.sourceLong = location.coordinate.longitude
        location.coordinate.lookupPlacemark(completionHandler: { (placemark) in
            if let placemark = placemark, !placemark.fullAddress.isEmpty {
                SharedObjects.shared.activeTrip?.sourceAddress = placemark.fullAddress
                if let trip = SharedObjects.shared.activeTrip, let tripId = self.startTrip(trip: trip) {
                    print(tripId)
                    LocationManager.shared.delegate = self
                    self.currentTripId = tripId
                    self.currentLocation = location
                    self.addSpot(location: location)
                }
            } else {
                print("❌ Source Placemark is not available")
            }
        })
    }
    
    @IBAction func stopButtonPressed(_ sender: Any) {
        isStarted = false
        guard let location = LocationManager.shared.userLocation else {
            return
        }
        
        removeOverlays()
        removeAnnotations()
        
        SharedObjects.shared.activeTrip?.endedAt = Date().timeIntervalSinceReferenceDate
        SharedObjects.shared.activeTrip?.destinationLat = location.coordinate.latitude
        SharedObjects.shared.activeTrip?.destinationLong = location.coordinate.longitude
        location.coordinate.lookupPlacemark(completionHandler: { (placemark) in
            if let placemark = placemark, !placemark.fullAddress.isEmpty {
                SharedObjects.shared.activeTrip?.destinationAddress = placemark.fullAddress
                LocationManager.shared.stopLocation()
                if let trip = SharedObjects.shared.activeTrip {
                    self.stopTrip(trip: trip)
                }
            }  else {
                print("❌ Destination Placemark is not available")
            }
            print(SharedObjects.shared.activeTrip)
        })
    }
    
    @IBAction func addStopButtonPressed(_ sender: UIButton) {
        guard let spotKey = currentSpotkey else {
            return
        }
        let spotInfoVC = UIStoryboard.main.instantiateViewController(withIdentifier: "SpotInfoViewController") as! SpotInfoViewController
        spotInfoVC.selectedSpotKey = spotKey
        spotInfoVC.selectedLocation = currentLocation
        spotInfoVC.delegate = self
        self.present(spotInfoVC, animated: true, completion: nil)
    }
    
    
    func removeOverlays() {
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
    }
    
    func removeAnnotations() {
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
    }
    
    //MARK: - Methods
    fileprivate func startTrip(trip: Trip) -> String? {
        if let userId = UserManager.shared.userId, trip != nil {
            let tripsRef = dbRef.child("trips").child(userId).childByAutoId()
            tripsRef.setValue(["title": "Mark my trip",
                               "tripId": tripsRef.key ?? "",
                               "sourceAddress": trip.sourceAddress ?? "",
                               "sourceLat": trip.sourceLat ?? 0.0,
                               "sourceLong": trip.sourceLong ?? 0.0,
                               "startedAt": trip.startedAt ?? 0.0])
            return tripsRef.key
        }
        return nil
    }
    
    fileprivate func stopTrip(trip: Trip) {
        if let userId = UserManager.shared.userId {
            let destinationAddPath = "trips/\(userId)/\(currentTripId ?? "")/destinationAddress"
            let destinationLat = "trips/\(userId)/\(currentTripId ?? "")/destinationLat"
            let destinationLng = "trips/\(userId)/\(currentTripId ?? "")/destinationLong"
            let endedAt = "trips/\(userId)/\(currentTripId ?? "")/endedAt"
            let _ = dbRef.child(destinationAddPath).setValue(trip.destinationAddress ?? "")
            let _ = dbRef.child(destinationLat).setValue(trip.destinationLat ?? 0.0)
            let _ = dbRef.child(destinationLng).setValue(trip.destinationLong ?? 0.0)
            let _ = dbRef.child(endedAt).setValue(trip.endedAt ?? 0.0)
        }
    }
    
    fileprivate func addSpot(location: CLLocation) {
        let spotsRef = dbRef.child("spots").child(currentTripId).childByAutoId()
        spotsRef.setValue(["lat": location.coordinate.latitude,
                           "lng":location.coordinate.longitude,
                           "createdAt": Date().timeIntervalSinceReferenceDate])
        self.currentSpotkey = spotsRef.key
    }
}

extension AddTripViewController: LocationManagerDelegate {
    func didFailWithError(error: Error) {
        print(error.localizedDescription)
    }
    
    func didUpdateLocation(location: CLLocation) {
        if(isStarted) {
            removeOverlays()
            points.append(location.coordinate)
            let polyline = MKPolyline(coordinates: points, count: points.count)
            mapView?.addOverlay(polyline)
            self.addSpot(location: location)
            self.currentLocation = location
        }
    }
}

extension AddTripViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKPolyline.self){
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.fillColor = UIColor.blue
            polylineRenderer.strokeColor = UIColor.blue
            polylineRenderer.lineWidth = 2
            
            return polylineRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}

extension AddTripViewController: SpotInfoDelegate {
    
    func didSelectedSpot(spotKey: String, location: CLLocation, image: UIImage?, comments: String?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let comments = comments, !comments.isEmpty {
                let commentPath = "spots/\(self.currentTripId ?? "")/\(spotKey)/comment"
                let _ = self.dbRef.child(commentPath).setValue(comments)
            }
            
            if let img = image {
                if let base64 = img.toBase64() {
                    let imagePath = "spots/\(self.currentTripId ?? "")/\(spotKey)/base64Image"
                    let _ = self.dbRef.child(imagePath).setValue(base64)
                    print("\n**********")
                    print("\(imagePath)")
                    print("✅ Image Added Successfully to \(spotKey)")
                    print("************\n")
                }
            }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            annotation.title = "\(location.coordinate.latitude), \(location.coordinate.longitude)"
            self.mapView.addAnnotation(annotation)
        }
    }
}
