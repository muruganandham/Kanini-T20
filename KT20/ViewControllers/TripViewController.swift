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
import NVActivityIndicatorView

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
                self?.fetchTrips()
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
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                ViewManager.shared.activityIndicatorView.startAnimating(ActivityData())
            }
            if let userID = Auth.auth().currentUser?.uid {
                let ref = Database.database().reference(withPath: "trips/\(userID)").queryOrdered(byChild: "startedAt")
                ref.observeSingleEvent(of: .value, with: { snapshot in
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                        ViewManager.shared.activityIndicatorView.stopAnimating()
                    }
                    
                    if !snapshot.exists() {
                        self.refreshControl.endRefreshing()
                        return
                    }
                    print(snapshot)
                    if let tempDic: Dictionary = snapshot.value as? Dictionary<String, Any> {
                        self.tripArray.removeAll()
                        var tempArray: [Trip] = []
                        self.tripsDictionary = tempDic
                        _ = tempDic.forEach({ dict in
                            let jsonData = try! JSONSerialization.data(withJSONObject: dict.value, options: JSONSerialization.WritingOptions.prettyPrinted)
                            let decoder = JSONDecoder()
                            do {
                                let tripObj = try decoder.decode(Trip.self, from: jsonData)
                                tempArray.append(tripObj)
                            } catch {
                                print(error.localizedDescription)
                            }
                        })
                        self.tripArray = tempArray.sorted { (trip1, trip2) -> Bool in
                            return trip1.startedAt ?? 0.0 > trip2.startedAt ?? 0.0
                        }
                        self.tripsTableView.reloadData()
                        self.refreshControl.endRefreshing()
                    }
                })
            }
        }
    }
    
    //MARK: - Methods
    
    @objc func onBackButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Sign out", message: "Are you sure you want to sign out?", preferredStyle: .alert)
        let signOutAction = UIAlertAction(title: "Sign out", style: .destructive) { [weak self] (action) in
            guard let self = self else { return }
            do {
                let firebaseAuth = Auth.auth()
                try firebaseAuth.signOut()
                print("Sign Out")
                self.present(self.loginVC, animated: true, completion: nil)
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }
        alert.addAction(signOutAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        let addTripVC = UIStoryboard.main.instantiateViewController(withIdentifier: "AddTripViewController") as! AddTripViewController
        addTripVC.didClose = { [weak self] in
            self?.fetchTrips()
        }
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
        if self.tripArray.isEmpty {
            tableView.setEmptyView(title: "No results", message: "", messageImage: UIImage())
            return 0
        }
        tableView.restore()
        return self.tripArray.count
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
        let tripObj = self.tripArray[indexPath.row]
        cell.sourceLabel.text = tripObj.sourceAddress
        cell.destLabel.text = tripObj.destinationAddress
        let locImage = UIImage(named: "menu_track_loc")
        cell.sourceIcon.image = locImage
        cell.destIcon.image = locImage
        if let sT = tripObj.startedAt {
            let sDate = Date(timeIntervalSinceReferenceDate: sT)
            cell.dateLabel.text = DateFormatter.monthDateFormatter.string(from: sDate)
            cell.sourceTimeLabel.text = DateFormatter.timeFormatter.string(from: sDate)
        }
        if let eT = tripObj.endedAt {
            let eDate = Date(timeIntervalSinceReferenceDate: eT)
            cell.destTimeLabel.text = DateFormatter.timeFormatter.string(from: eDate)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let tripObj = self.tripArray[indexPath.row]
        print(tripObj.tripId)
        let spotVC = UIStoryboard.main.instantiateViewController(withIdentifier: "SpotsViewController") as! SpotsViewController
        spotVC.tripId = tripObj.tripId
        self.navigationController?.pushViewController(spotVC, animated: true)
    }
}
