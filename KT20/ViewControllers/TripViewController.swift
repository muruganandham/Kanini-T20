//
//  TripViewController.swift
//  KT20
//
//  Created by Muruganandham on 30/10/20.
//

import UIKit
import Firebase
import GoogleSignIn

class TripViewController: UIViewController {

    let loginVC = UIStoryboard.main.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu_logout"), style: .plain, target: self, action: #selector(onBackButton(_:)))
        
        loginVC.modalPresentationStyle = .custom
        loginVC.onLogIn = { [weak self] user in
            self?.loginVC.dismiss(animated: true) {
                print("dismissed")
            }
        }
        loginVC.onLogOut = {
            
        }
        
        let user = Auth.auth().currentUser
        if(user == nil ) {
            self.present(loginVC, animated: true, completion: nil)
        } else {
            print("user: \(user?.email)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @objc func onBackButton(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("Sign Out")
            self.present(loginVC, animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        return
    }

}
