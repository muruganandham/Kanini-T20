//
//  TripViewController.swift
//  KT20
//
//  Created by Muruganandham on 30/10/20.
//

import UIKit

class TripViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings"), style: .plain, target: self, action: #selector(onBackButton(_:)))
    }
    

    @objc func onBackButton(_ sender: UIBarButtonItem) {
        
    }

}
