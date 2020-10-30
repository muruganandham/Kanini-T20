//
//  ViewController.swift
//  KT20
//
//  Created by Muruganandham on 29/10/20.
//

import UIKit
import Firebase
import GoogleSignIn

class ViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = Auth.auth().currentUser {
            print(user.uid)
            print(user.email)
            print(user.displayName)
        }
    }
    
    fileprivate func addUser() {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child("users").childByAutoId().setValue(["username": usernameTextField.text!, "createdOn": Date().timeIntervalSinceReferenceDate])
    }

    @IBAction func goButtonAction(_ sender: Any) {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
        GIDSignIn.sharedInstance().delegate = self
        
//        let firebaseAuth = Auth.auth()
//        do {
//          try firebaseAuth.signOut()
//            print("Sign Out")
//        } catch let signOutError as NSError {
//          print ("Error signing out: %@", signOutError)
//        }
    }
    
}

extension ViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            print(authResult?.user.uid)
            print("User is signed in...")
        }
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print(error.localizedDescription)
    }
}
