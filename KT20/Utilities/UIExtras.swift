//
//  UIExtras.swift
//  KT20
//
//  Created by Muruganandham on 30/10/20.
//

import Foundation
import UIKit
import CoreLocation

extension UIStoryboard {
    class var main: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: Bundle.main)
    }
}

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex: Int) {
        self.init(red: (netHex >> 16) & 0xff, green: (netHex >> 8) & 0xff, blue: netHex & 0xff)
    }
}

extension CLLocationCoordinate2D {
    
    // Get a CLPlacemark for this location
    func lookupPlacemark(completionHandler: @escaping (CLPlacemark?) -> Void) {
        
        // Look up the location and pass it to the completion handler
        let selectedLocation = CLLocation(latitude: latitude, longitude: longitude)
        CLGeocoder().reverseGeocodeLocation(selectedLocation, completionHandler: { (placemarks, error) in
            
            if error == nil {
                completionHandler(placemarks?.first)
            } else {
                // An error occurred during geocoding.
                print("Error looking up location: \(error!)")
                completionHandler(nil)
            }
        })
    }
}

extension CLPlacemark {
    var customAddress: String {
        return [[thoroughfare, subThoroughfare], [postalCode, locality]]
            .map { (subComponents) -> String in
                subComponents.compactMap({ $0 }).joined(separator: " ")
            }
            .filter({ return !$0.isEmpty })
            .joined(separator: ", ")
    }
    
    var placeName: String? {
        var names: [String?] = [name, thoroughfare]
        names.append(contentsOf: areasOfInterest ?? [])
        return names
            .compactMap({ $0 })
            .first
    }
    
    var fullAddress: String {
        return  [placeName, customAddress]
            .compactMap({ $0 })
            .filter({ return !$0.isEmpty })
            .joined(separator: ", ")
    }
}
