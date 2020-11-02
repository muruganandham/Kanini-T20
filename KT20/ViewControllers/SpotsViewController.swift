//
//  SpotsViewController.swift
//  KT20
//
//  Created by Muruganandham on 30/10/20.
//

import UIKit
import MapKit

class SpotsViewController: UIViewController {
    
    var routeDict: Dictionary<String, Any>?
    var spotArray = [Spot]()
    
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
        
        var points: [CLLocationCoordinate2D] = []
        var center: CLLocationCoordinate2D?
        
        let ss = routeDict?.forEach({ dict in
            
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
            print("locPoint.image: \(locPoint.base64Image)")
            
            if !(locPoint.base64Image?.isEmpty ?? true) {
                let annotation = MKPointAnnotation()
                annotation.coordinate = point
                annotation.title = "\(point.latitude), \(point.longitude)"
                mapView.addAnnotation(annotation)
                }
            })
        
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        
        let polyline = MKPolyline(coordinates: points, count: points.count)
        mapView?.addOverlay(polyline)
        
        UIView.animate(withDuration: 1.5, animations: { () -> Void in
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region1 = MKCoordinateRegion(center: center!, span: span)
            self.mapView.setRegion(region1, animated: true)
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
}
