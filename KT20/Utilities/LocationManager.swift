//
//  Constants.swift
//  KT20
//
//  Created by Muruganandham on 30/10/20.
//

import UIKit
import CoreLocation
import MapKit

public typealias userCLLocation = ((_ location: CLLocation?) -> Void)


protocol LocationManagerDelegate: class {
    func didUpdateLocation(location: CLLocation)
    func didFailWithError(error: Error)
}

/**
 Helper object around location logic on iOS.
 */
public class LocationManager: NSObject {
    
    static let shared = LocationManager()
    private(set) var userLocation: CLLocation? {
        didSet {
            if let location = self.userLocation {
                let formattedString = String(format: "POINT(%1.8f %1.8f) 4326", location.coordinate.longitude, location.coordinate.latitude)
                self.formattedUserLocation = formattedString
            }
        }
    }
    //private var onRequestUserLocation: userCLLocation?
    private var locationManager: CLLocationManager!
    private(set) var formattedUserLocation: String?
    weak var delegate: LocationManagerDelegate?
    
//    private enum Mode {
//        case None
//        case Single
//        case Track
//    }
//    private var mode = Mode.None
    weak private(set) var timer: Timer?
    
    override init() {
        super.init()
        DispatchQueue.main.async {
            self.locationManager = CLLocationManager()
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.distanceFilter = 10.0
            if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined {
                self.locationManager.requestAlwaysAuthorization()
            }
            self.locationManager.delegate = self
            self.startLocation()
            _ = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "breadcrumbsStatusChanged"), object: nil, queue: nil) { _ in
                if !Constants.trailId.isEmpty { // It will invoke When user starts Breadcrumbs, Next time timer will take care of each 10sec sync.
                    self.updateUserLocation()
                }
                self.updateBreadcrumbsRecording()
            }
        }
    }
    
    // Start getting location
    public func startLocation() {
        locationManager?.startUpdatingLocation()
    }

    // Stop getting location
    public func stopLocation() {
        locationManager?.stopUpdatingLocation()
    }
//
//    // Start keeping a record of location, eventually to make a PolyLine
//    // No callback for this one
//    public func startLocationTrack() {
//        mode = .Track
//        locationManager?.startUpdatingLocation()
//        // For tracks we want a lot more detail
//        locationManager.distanceFilter = 3.0
//    }
//
//    // Switch from tracking to single mode
//    public func stopLocationTrack() {
//        mode = .Single
//        locationTrack = nil
//    }
    
    // Used when making a polyline track
//    fileprivate var locationTrack: [CLLocationCoordinate2D]?
//
    // Start requesting the location updates
//    func getUserLocation(location: @escaping userCLLocation) {
//        startLocation()
//        onRequestUserLocation = location
//    }
    
    // Return the current location track since when we started recording
//    func getUserTrack() -> [CLLocationCoordinate2D] {
//        guard let track = locationTrack else {
//            return []
//        }
//        
//        return track
//    }
//
//    // Return true if we're actively tracking
//    func isTracking() -> Bool {
//        return locationTrack != nil
//    }
    
    static func showEnableLocationAlert() {
        let alert = UIAlertController(title: "Allow Location Access", message: "This app needs access to your location. Turn on Location Services in your device settings.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Settings", style: UIAlertAction.Style.default, handler: { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        }))
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController!.present(alert, animated: true, completion: nil)
    }
    
    private func updateBreadcrumbsRecording() {
        if !Constants.trailId.isEmpty {
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { [weak self] _ in
                self?.updateUserLocation()
            }
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.showsBackgroundLocationIndicator = true
        } else {
            timer?.invalidate()
            locationManager.allowsBackgroundLocationUpdates = false
            locationManager.showsBackgroundLocationIndicator = false
        }
    }
    
    // Update user location to the server using Breaadcrumbs API
    private func updateUserLocation() {
//        if let userLoc = self.userLocation {
//            let param: [String: Any] = ["longitude": userLoc.coordinate.longitude,
//                                        "latitude": userLoc.coordinate.latitude,
//                                        "horizontalAccuracy": userLoc.horizontalAccuracy,
//                                        "speed": userLoc.speed,
//                                        "speedAccuracy": 0,
//                                        "altitude": userLoc.altitude,
//                                        "verticalAccuracy": userLoc.verticalAccuracy,
//                                        "course": userLoc.course,
//                                        "courseAccuracy": 0,
//                                        "deviceOrAdvertisingId": UUID().uuidString.lowercased(),
//                                        "trailId": Constants.trailId]
//            }
 //       }
    }
}

//MARK: - LocationManager Delegate
extension LocationManager: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager?.requestAlwaysAuthorization()
        case .denied, .restricted:
            LocationManager.showEnableLocationAlert()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager?.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error:\(NSError.description())")
        self.delegate?.didFailWithError(error: error)
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard locations.count > 0, let lastLocation = locations.last else {
            return
        }
        userLocation = lastLocation
        self.delegate?.didUpdateLocation(location: lastLocation)
//        print(userLocation)
        //onRequestUserLocation?(userLocation)
//        switch mode {
//        case .None:
//            // Shouldn't happen
//            break
//        case .Single:
//            onRequestUserLocation?(userLocation)
//        case .Track:
//            if locationTrack == nil {
//                locationTrack = [CLLocationCoordinate2D]()
//            }
//            if let location2d = userLocation?.coordinate {
//                locationTrack?.append(location2d)
//            }
//        }
    }
}

extension CLLocationManager {
    static func authorizedToRequestLocation() -> Bool {
        return CLLocationManager.locationServicesEnabled() &&
            (CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse)
    }
}
