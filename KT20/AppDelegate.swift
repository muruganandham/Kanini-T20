//
//  AppDelegate.swift
//  KT20
//
//  Created by Muruganandham on 29/10/20.
//

import UIKit
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        //GIDSignIn.sharedInstance().delegate = self
        
//        var ref: DatabaseReference!
//
//        ref = Database.database().reference()
//        print(ref)
//        ref.child("Trips").setValue(["username": "Ezhil", "id": "980", "createdOn": "\(Date())"])
        
//        let ref = Database.database().reference(withPath: "Users")
//        ref.observeSingleEvent(of: .value, with: { snapshot in
//
//            if !snapshot.exists() { return }
//
//            print(snapshot) // Its print all values including Snap (User)
//
//            print(snapshot.value!)
//
//            let username = snapshot.childSnapshot(forPath: "username").value
//            print(username!)
//
//        })
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
      -> Bool {
      return GIDSignIn.sharedInstance().handle(url)
    }


}

