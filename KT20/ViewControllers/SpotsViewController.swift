//
//  SpotsViewController.swift
//  KT20
//
//  Created by Muruganandham on 30/10/20.
//

import UIKit
import MapKit
import Firebase
import NVActivityIndicatorView

class SpotsViewController: UIViewController {
    
    var routeDict: Dictionary<String, Any>? {
        didSet {
            setupUI()
        }
    }
    var spotArray = [Spot]()
    var tripId: String?
    var points: [CLLocationCoordinate2D] = []
    var center: CLLocationCoordinate2D?
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.mapType = MKMapType.standard
            mapView.isZoomEnabled = true
            mapView.isScrollEnabled = true
            mapView.showsUserLocation = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Spots"
        
        mapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(CustomAnnotation.self))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            ViewManager.shared.activityIndicatorView.startAnimating(ActivityData())
        }
        self.getSpotsBy(tripId: self.tripId ?? "", success: { (dictionary) in
            self.routeDict = dictionary
        }) { (errorString) in
            print("error: \(errorString)")
        }
    }
    
    func setupUI() {
        _ = routeDict?.forEach({ dict in
            let jsonData = try! JSONSerialization.data(withJSONObject: dict.value, options: JSONSerialization.WritingOptions.prettyPrinted)
            let decoder = JSONDecoder()
            do {
                let spotObj = try decoder.decode(Spot.self, from: jsonData)
                spotArray.append(spotObj)
            } catch {
                print(error.localizedDescription)
            }
        })
        
        let sortedArray = spotArray.sorted { (spot, spot2) -> Bool in
            return spot.createdAt ?? 0.0 > spot2.createdAt ?? 0.0
        }
        
        sortedArray.forEach({ (locPoint) in
            let lat = locPoint.lat
            let lng = locPoint.lng
            
            let point = CLLocationCoordinate2DMake(lat!, lng!);
            if(center == nil) {
                center = point
            }
            points.append(point)
            if !(locPoint.base64Image?.isEmpty ?? true) {
                let imageAnnotation = CustomAnnotation(coordinate: point)
                imageAnnotation.title = locPoint.comment ?? ""
                imageAnnotation.image = locPoint.base64Image?.getImageFromBase64()
                mapView.addAnnotation(imageAnnotation)
            }
        })
        
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        
        let polyline = MKPolyline(coordinates: points, count: points.count)
        mapView?.addOverlay(polyline)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            ViewManager.shared.activityIndicatorView.stopAnimating()
        }
        
        UIView.animate(withDuration: 1.5, animations: { () -> Void in
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region1 = MKCoordinateRegion(center: self.center!, span: span)
            self.mapView.setRegion(region1, animated: true)
        })
    }
    
    fileprivate func getSpotsBy(tripId: String, success: @escaping(Dictionary<String, Any>) -> Void, error: @escaping(String) -> Void) {
        let spotsRef = Database.database().reference(withPath: "spots/\(tripId)").queryOrdered(byChild: "createdAt")
        spotsRef.observeSingleEvent(of: .value, with: { snapshot in
            if !snapshot.exists() {
                return
            }
            if let spotsDict: Dictionary = snapshot.value as? Dictionary<String, Any> {
                success(spotsDict)
            }
        })
    }
}

extension SpotsViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKPolyline.self){
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.fillColor = UIColor.blue
            polylineRenderer.strokeColor = UIColor.blue
            polylineRenderer.lineWidth = 2
            return polylineRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else {
            // Make a fast exit if the annotation is the `MKUserLocation`, as it's not an annotation view we wish to customize.
            return nil
        }
        var annotationView: MKAnnotationView?
        if let annotation = annotation as? CustomAnnotation {
            annotationView = setupCustomAnnotationView(for: annotation, on: mapView)
        }
        return annotationView
    }
    
    
    private func setupCustomAnnotationView(for annotation: CustomAnnotation, on mapView: MKMapView) -> MKAnnotationView {
        return mapView.dequeueReusableAnnotationView(withIdentifier: NSStringFromClass(CustomAnnotation.self), for: annotation)
    }
}
