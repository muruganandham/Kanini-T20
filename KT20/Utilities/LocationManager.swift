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

public class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationManager()
    public var userLocation: CLLocation?
    private var onRequestUserLocation: userCLLocation?
    private var locationManager: CLLocationManager!
    
    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1000
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        startLocation()
    }
    
    public func startLocation()  {
        locationManager.startUpdatingLocation()
    }
    
    public func stopLocation()  {
        locationManager.stopUpdatingLocation()
    }
    
    func getUserLocation(location: @escaping userCLLocation) -> Void {
        startLocation()
        onRequestUserLocation = location
    }
    
    //MARK:- locationManager Delegate
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager?.requestAlwaysAuthorization()
        case .denied,.restricted:
            locationManager = nil
        case .authorizedWhenInUse,.authorizedAlways:
            locationManager?.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error:\(NSError.description())")
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard locations.count > 0 else{
            return
        }
        
        let location = CLLocation(latitude: locations.last!.coordinate.latitude, longitude: locations.last!.coordinate.longitude)
        print(location.coordinate.latitude)
        print(location.coordinate.longitude)
        userLocation = location
        onRequestUserLocation?(userLocation)
    }
}
