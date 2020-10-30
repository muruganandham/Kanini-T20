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
        
        let tripVC = UIStoryboard.main.instantiateViewController(withIdentifier: "TripViewController") as! TripViewController
        self.navigationController?.pushViewController(tripVC, animated: animated)
    }
    
    // MARK: - Add User defined methods
    
}

