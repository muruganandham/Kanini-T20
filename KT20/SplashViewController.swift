//
//  ViewController.swift
//  KT20
//
//  Created by Muruganandham on 29/10/20.
//

import UIKit

class SplashViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sleep(1)
        // TODO: Splash animation here
        print("start...")
        
        if(1==1) {
            let tripVC = UIStoryboard.main.instantiateViewController(withIdentifier: "TripViewController") as! TripViewController
            self.navigationController?.pushViewController(tripVC, animated: animated)

        } else {
            let loginVC = UIStoryboard.main.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            loginVC.modalPresentationStyle = .custom
            self.present(loginVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - Add User defined methods
    
}

