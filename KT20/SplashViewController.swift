//
//  ViewController.swift
//  KT20
//
//  Created by Muruganandham on 29/10/20.
//

import UIKit
import Lottie

class SplashViewController: UIViewController {
    
    @IBOutlet weak var animationView: AnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        
//        LocationManager.shared.getUserLocation(location: { (location) in
//            print(location?.coordinate.latitude ?? 0.0)
//            print(location?.coordinate.longitude ?? 0.0)
//        })
    }
    
    func playAnimation(){
        animationView.animation = Animation.named("6843-map-location")
        //animationView.loopMode = .loop
        animationView.play { (finished) in
            let tripVC = UIStoryboard.main.instantiateViewController(withIdentifier: "TripViewController") as! TripViewController
            self.navigationController?.pushViewController(tripVC, animated: true)
        }
    }
    
    // MARK: - Add User defined methods
    
}

