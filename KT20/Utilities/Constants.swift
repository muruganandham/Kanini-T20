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
    var lat: Double?
    var lng: Double?
    var createdAt: Double?
    
    enum CodingKeys: String, CodingKey {
        case note
        case image
        case lat
        case lng
        case createdAt
    }
}

public struct Trip: Codable {
    var sourceAddress: String?
    var sourceLat: Double?
    var sourceLong: Double?
    var destinationAddress: String?
    var destinationLat: Double?
    var destinationLong: Double?
    var startedAt: Double?
    var endedAt: Double?
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
        case startedAt
        case endedAt
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
