//
//  Constants.swift
//  KT20
//
//  Created by Muruganandham on 30/10/20.
//

import Foundation

struct Spot: Codable {
    var note: String?
    var image: String? // base64
    var lat: String?
    var long: String?
    
    enum CodingKeys: String, CodingKey {
        case note
        case image
        case lat
        case long
    }
}

public struct Trip: Codable {
    var sourceAddress: String?
    var sourceLat: String?
    var sourceLong: String?
    var destinationAddress: String?
    var destinationLat: String?
    var destinationLong: String?
    var startTime: Date?
    var endTime: Date?
    var kms: Double?
    var tripId: String?
    var spots: [Spot?]?
    var route: String?
    var routeArray: [String]?

    enum CodingKeys: String, CodingKey {
        case sourceAddress
        case sourceLat
        case sourceLong
        case destinationAddress
        case destinationLat
        case destinationLong
        case startTime
        case endTime
        case kms
        case tripId
        case spots
        case route
        case routeArray
    }
}

struct Constants {
    
    static var trailId: String {
        get {
            return UserDefaults.standard.value(forKey: "trailId") as? String ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "trailId")
            UserDefaults.standard.synchronize()
        }
    }
}
