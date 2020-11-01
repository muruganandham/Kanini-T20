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
        print("routeDict: \(routeDict)")

        var points: [CLLocationCoordinate2D] = []
        var center: CLLocationCoordinate2D?
        routeDict?.forEach({ (point) in
            
            let latLong: Dictionary = point.value as! Dictionary<String, NSNumber?>
            print(latLong)
 
            let lat: NSNumber = latLong["lat"]!!
            let lng: NSNumber = latLong["lng"]!!
            
            print("----")
            print(lat)
            print(lng)
            
            let point = CLLocationCoordinate2DMake(Double(truncating: lat), Double(truncating: lng));
            if(center == nil) {
                center = point
            }
            points.append(point)
        })
        
        print("points: \(points)")
        
//        let point1 = CLLocationCoordinate2DMake(-73.761105, 41.017791);
//        let point2 = CLLocationCoordinate2DMake(-73.760701, 41.019348);
//        let point3 = CLLocationCoordinate2DMake(-73.757201, 41.019267);
//        let point4 = CLLocationCoordinate2DMake(-73.757482, 41.016375);
//
//
//
//        points.append(point1)
//        points.append(point2)
//        points.append(point3)
//        points.append(point4)
        
        let geodesic = MKGeodesicPolyline(coordinates: points, count: points.count)
        mapView.addOverlay(geodesic)
        
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
