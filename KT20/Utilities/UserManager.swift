//
//  UserManager.swift
//  KT20
//
//  Created by Ezhil Adhavan Ananthavel on 31/10/20.
//

import Foundation
import Firebase

class UserManager {
    static let shared = UserManager()
    
    var userId: String? {
        return Auth.auth().currentUser?.uid
    }
}
