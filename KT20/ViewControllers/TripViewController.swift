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
    var tripArray = [Trip]()
    
    @IBOutlet weak var tripsTableView: UITableView!
    @IBOutlet weak var addButton: UIButton! {
        didSet {
            addButton.layer.cornerRadius = addButton.frame.size.height / 2.0
            addButton.layer.masksToBounds = true
        }
    }
    var tripsDictionary: Dictionary<String, Any>?
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu_logout"), style: .plain, target: self, action: #selector(onBackButton(_:)))
        self.title = "Home"
        
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
        refreshControl.tintColor = .white
        
        if #available(iOS 10.0, *) {
            tripsTableView.refreshControl = refreshControl
        } else {
            tripsTableView.addSubview(refreshControl)
        }
        
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
            self.present(loginVC, animated: false, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        fetchTrips()
        
    }
    
    @objc private func refreshWeatherData(_ sender: Any) {
        fetchTrips()
    }
    
    func fetchTrips() {
        let user = Auth.auth().currentUser
        if(user != nil )  {
            if let userID = Auth.auth().currentUser?.uid {
                let ref = Database.database().reference(withPath: "trips/\(userID)")
                ref.observeSingleEvent(of: .value, with: { snapshot in
                    if !snapshot.exists() {
                        return
                    }
                    if let tempDic: Dictionary = snapshot.value as? Dictionary<String, Any> {
                        self.tripsDictionary = tempDic
                        self.tripsTableView.reloadData()
                        self.refreshControl.endRefreshing()
                    }
                })
            }
        }
    }
    
    //MARK: - Methods
    fileprivate func getSpotsBy(tripId: String, success: @escaping(Dictionary<String, Any>) -> Void, error: @escaping(String) -> Void) {
        let spotsRef = Database.database().reference(withPath: "spots/\(tripId)")
        spotsRef.observeSingleEvent(of: .value, with: { snapshot in
            if !snapshot.exists() {
                return
            }
            if let spotsDict: Dictionary = snapshot.value as? Dictionary<String, Any> {
                success(spotsDict)
            }
        })
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
        
        guard let trips = self.tripsDictionary?.keys, !trips.isEmpty else {
            return UITableViewCell()
        }
        let key = Array(trips)[indexPath.row]
        if let dict = self.tripsDictionary?[key] {
            print("dict: \(dict)")
            let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)
            let decoder = JSONDecoder()
            do {
                let tripObj = try decoder.decode(Trip.self, from: jsonData)
                cell.sourceLabel.text = tripObj.sourceAddress
                cell.destLabel.text = tripObj.destinationAddress
            } catch {
                print(error.localizedDescription)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let tripsDict = self.tripsDictionary else {
            return
        }
        let tripsArray = Array(tripsDict.keys)
        self.getSpotsBy(tripId: tripsArray[indexPath.row]) { (dictionary) in
            let spotVC = UIStoryboard.main.instantiateViewController(withIdentifier: "SpotsViewController") as! SpotsViewController
            spotVC.routeDict = dictionary
            print(dictionary)
            self.navigationController?.pushViewController(spotVC, animated: true)
        } error: { (errorString) in
            print("error: \(errorString)")
        }
    }
}
