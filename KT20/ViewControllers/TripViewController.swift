//
//  TripViewController.swift
//  KT20
//
//  Created by Muruganandham on 30/10/20.
//

import UIKit
import Firebase
import GoogleSignIn
import Floaty

class TripViewController: UIViewController {

    let loginVC = UIStoryboard.main.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
    
    @IBOutlet weak var tripsTableView: UITableView!
    @IBOutlet weak var addButton: UIButton! {
        didSet {
            addButton.layer.cornerRadius = addButton.frame.size.height / 2.0
            addButton.layer.masksToBounds = true
        }
    }
    var tripsDictionary: Dictionary<String, Any>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu_logout"), style: .plain, target: self, action: #selector(onBackButton(_:)))
        self.title = "Home"
        
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
            if let userID = Auth.auth().currentUser?.uid {
                let ref = Database.database().reference(withPath: "trips/\(userID)")
                ref.observeSingleEvent(of: .value, with: { snapshot in
                    if !snapshot.exists() {
                        return
                    }
                    if let tempDic: Dictionary = snapshot.value as? Dictionary<String, Any> {
                        print(tempDic.keys)
                        self.tripsDictionary = tempDic
                        self.tripsTableView.reloadData()
                    }
                })
            }
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
    
    @IBAction func addButtonPressed(_ sender: Any) {
        
        let addTripVC = UIStoryboard.main.instantiateViewController(withIdentifier: "AddTripViewController") as! AddTripViewController
        self.present(addTripVC, animated: true, completion: nil)
        self.startTrip()
    }
    
    fileprivate func startTrip() {
        if let userId = UserManager.shared.userId {
            var ref: DatabaseReference!
            ref = Database.database().reference()
            let tripsRef = ref.child("trips").child(userId).childByAutoId()
            tripsRef.setValue(["title":"A",
                               "sourceAddress": "",
                               "destinationAddress": "",
                               "sourceLat": 0.0,
                               "sourceLong": 0.0,
                               "destinationLat": 0.0,
                               "destinationLong": 0.0,
                               "startedAt": Date().timeIntervalSinceReferenceDate,
                               "endedAt": Date().timeIntervalSinceReferenceDate,
                               "kms": 5.0])
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension TripViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let trips = self.tripsDictionary?.keys, !trips.isEmpty else {
            tableView.setEmptyView(title: "No results", message: "", messageImage: UIImage())
                return 0
        }
        tableView.restore()
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutIfNeeded()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TripTableViewCell",
            for: indexPath) as! TripTableViewCell
        //cell.fileName = ActivityPdfAttachmentTableViewCell.fileNameWithIndex(indexPath.row + 1)
        //cell.attachment = pdfAttachment
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let spotVC = UIStoryboard.main.instantiateViewController(withIdentifier: "SpotsViewController") as! SpotsViewController
        self.navigationController?.pushViewController(spotVC, animated: true)
    }
}
