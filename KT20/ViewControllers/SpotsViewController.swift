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
        
        let sortedArray = routeDict?.sorted(by: { item1, item2 in
            
            let dict1 = item1.value as! Dictionary<String, Any>
            let dict2 = item2.value as! Dictionary<String, Any>
            
            print("*****************")
            print("**\(dict1["createdAt"])")
            let string: String = "\(dict1["createdAt"])"
            print("**\(DateFormatter.iso8601Full.date(from: string))")
            print("*****************")

            return true
        })
        
        sortedArray?.forEach({ (point) in
            
            let latLong: Dictionary = point.value as! Dictionary<String, Any>
            print("latLong: \(latLong)")
            
            let lat: NSNumber = latLong["lat"]! as! NSNumber
            let lng: NSNumber = latLong["lng"]! as! NSNumber
            
            print("----")
            print(lat)
            print(lng)
            
            
            let point = CLLocationCoordinate2DMake(lat.doubleValue, lng.doubleValue);
            if(center == nil) {
                center = point
            }
            
            points.append(point)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = point
            annotation.title = "\(point.latitude), \(point.longitude)"
            mapView.addAnnotation(annotation)
            
            print("point: \(point)")
        })
        
        print("points: \(points)")
        
        //        let point1 = CLLocationCoordinate2DMake(37.42261989, -122.22622172);
        //        let point2 = CLLocationCoordinate2DMake(37.41883236, -122.2175664);
        //        let point3 = CLLocationCoordinate2DMake(37.41926445, -122.22021307);
        //        //let point4 = CLLocationCoordinate2DMake(37.42384553, -122.22799483);
        //
        //        points.append(point1)
        //        points.append(point2)
        //        points.append(point3)
        //        //points.append(point4)
        //        center = point1
        
        //        let geodesic = MKGeodesicPolyline(coordinates: points, count: points.count)
        //        mapView.addOverlay(geodesic)
        
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
