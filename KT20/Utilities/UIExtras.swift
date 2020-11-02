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

extension UIView {
    func removeAllSubViews() {
        subviews.forEach { (subView) in
            subView.removeFromSuperview()
        }
    }
}

extension UITableView {
    func setEmptyView(title: String, message: String, messageImage: UIImage) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        let messageImageView = UIImageView()
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        messageImageView.backgroundColor = .clear
        messageImageView.contentMode = .scaleAspectFit
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageImageView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.font = UIFont.systemFont(ofSize: 22)
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageImageView)
        emptyView.addSubview(messageLabel)
        messageImageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        messageImageView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: -100).isActive = true
        messageImageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        messageImageView.heightAnchor.constraint(equalToConstant: messageImage == UIImage() ? 0.0 : 200).isActive = true
        titleLabel.topAnchor.constraint(equalTo: messageImageView.bottomAnchor, constant: 25).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15).isActive = true
        messageLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        messageLabel.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 20).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: -20).isActive = true
        messageImageView.image = messageImage
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        self.backgroundView = emptyView
        self.separatorStyle = .none
    }
    
    func restore() {
        self.backgroundView?.removeAllSubViews()
        self.separatorStyle = .none
    }
}

extension UIImage {
    func toBase64() -> String? {
        guard let imageData = self.jpegData(compressionQuality: 0.85) else { return nil }
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.endLineWithCarriageReturn)
    }
}

extension DateFormatter {
    static let monthDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh mm a"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static let iso8601Custom: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxx"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

extension UIButton {
    func disable() {
        self.isUserInteractionEnabled = false
        self.alpha = 0
    }
    
    func enable() {
        self.isUserInteractionEnabled = true
        self.alpha = 1.0
    }
}
