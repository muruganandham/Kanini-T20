//
//  LoginViewController.swift
//  KT20
//
//  Created by Muruganandham on 30/10/20.
//

import UIKit
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    
    var onLogIn: ((User?) -> Void)?
    var onLogOut: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateButtonToLogOut()
    }
    
    @IBAction func loginButtonAction(_ sender: UIButton) {
        if sender.tag == 2 {
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                print("Sign Out")
                self.onLogOut?()
                self.updateButtonToLogin()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            return
        }
        
        // Login Process
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
        GIDSignIn.sharedInstance().delegate = self
    }
    
    // MARK: - Methods
    fileprivate func addUser(userId: String, info: [String: Any]) {
        print(info)
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child("users").child(userId).setValue(info)
    }
    
    fileprivate func updateButtonToLogin() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.loginButton.setTitle("Log In with Google", for: .normal)
            self.loginButton.tag = 0
        }
        
    }
    
    fileprivate func updateButtonToLogOut() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let user = Auth.auth().currentUser {
                print(user.uid)
                print(user.email ?? "")
                print(user.displayName ?? "")
                self.loginButton.setTitle("Log Out", for: .normal)
                self.loginButton.tag = 2
            }
        }
    }
}

extension LoginViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
            guard let self = self else { return }
            if let error = error {
                print(error.localizedDescription)
            }
            print("User is signed in...")
            self.updateButtonToLogOut()
            if let user = authResult?.user {
                let info: [String: Any] = ["email": user.email ?? "",
                            "username": user.displayName ?? "",
                            "createdOn": Date().timeIntervalSinceReferenceDate]
                self.addUser(userId: user.uid, info: info)
                self.onLogIn?(user)
            }
        }
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print(error.localizedDescription)
    }
}
