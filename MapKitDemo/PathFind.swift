//
//  PathFind.swift
//  MapKitDemo
//
//  Created by RTC-HN154 on 11/7/19.
//  Copyright © 2019 RTC-HN154. All rights reserved.
//

import UIKit
import MapKit

class PathFind: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var fromLocation: CLLocation!
    var locationManager = CLLocationManager() // NSLocationWhenInUseUsageDescription
    
    var overlay: MKOverlay?     // vẽ tuyến đường đi
    var direction: MKDirections?
    var foundPlace: CLPlacemark?
    var geoCoder: CLGeocoder?   // chuyển đổi kiểu string sang kiểu CLPlacemark
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = .all
        self.mapView.delegate = self
        self.geoCoder = CLGeocoder()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()    // Bật lên hộp thoại để cho người dùng nhấn OK
        self.locationManager.startUpdatingLocation() // Sau khi người dùng nhấn OK sẽ lấy ra vị trí hiện tại
//        self.mapView.showsUserLocation = true   // Tạo điểm chấm xanh tại vị trí người dùng. ( Nếu ta custom annotation thì không cần gọi tới hàm này nữa)
        
    }
    
    // Delegate uitextfield
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if overlay != nil {
            self.mapView.removeOverlay(overlay!)
        }
        lookForAddress(textField.text!)
        return true
    }
    
    func lookForAddress(_ addressString: String) {
        if addressString == "" {
            return
        }
        self.geoCoder?.geocodeAddressString(addressString, completionHandler: { placemarks, error in
            if error == nil {
                self.foundPlace = placemarks?.first
                let toPlace = MKPlacemark(placemark: self.foundPlace!)
                self.routePath(MKPlacemark(coordinate: self.fromLocation.coordinate, addressDictionary: nil), toLocation: toPlace)
            }
        })
    }
    
    func routePath(_ fromPlace: MKPlacemark, toLocation: MKPlacemark) {
        let request = MKDirections.Request()
        let fromMapItem = MKMapItem(placemark: fromPlace)
        request.source = fromMapItem
        let toMapItem = MKMapItem(placemark: toLocation)
        request.destination = toMapItem
        self.direction = MKDirections(request: request)
        self.direction?.calculate(completionHandler: { response, error in
            if error == nil {
                self.showRoute(response!)
            }
        })
    }
  
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay)
        render.strokeColor = UIColor.blue
        render.lineWidth = 5.0
        return render
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()     // Nếu muốn update location của user theo sự di chuyển thì k dùng hàm này, hiện tại đang demo lấy tại 1 diểm nên stop k update location.
        self.fromLocation = locations.last
        self.updateRegion(2.0)
        
        // add annotation
        let annotation = LocationAnnotation(coordinate: fromLocation.coordinate, title: "Nguyễn Hạ Vy")
        self.mapView.addAnnotation(annotation)
    }
    
    func updateRegion(_ scale: CGFloat) {
        let size: CGSize = self.mapView.bounds.size
        let region = MKCoordinateRegion.init(center: fromLocation.coordinate, latitudinalMeters: Double(size.height * scale), longitudinalMeters: Double(size.width * scale))
        self.mapView.setRegion(region, animated: true)
    }
    
    // MARK: Tìm đường từ vị trí đang đứng tới một địa điểm
    
    
    func showRoute(_ response: MKDirections.Response) {
        for route in response.routes {
            self.overlay = route.polyline
            self.mapView.addOverlay(self.overlay!, level: .aboveRoads)
            for step in route.steps {
                print(step.instructions)
            }
        }
    }
    
    // Custom Annotation
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
        } else {
            annotationView?.annotation = annotation
        }
        let viewDetail = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        let labelName = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
        labelName.numberOfLines = 0
        labelName.text = "Love"
        labelName.textAlignment = .center
        let imgView = UIImageView(frame: CGRect(x: 0, y: 20, width: 200, height: 180))
        imgView.image = UIImage(named: "img")
        viewDetail.addSubview(labelName)
        viewDetail.addSubview(imgView)
        
        // Contraints
        let widthConstraint = NSLayoutConstraint(item: viewDetail, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200)
        let heightConstraint = NSLayoutConstraint(item: viewDetail, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200)
        viewDetail.addConstraints([widthConstraint, heightConstraint])
        
        annotationView?.detailCalloutAccessoryView = viewDetail
        annotationView?.image = UIImage(named: "love")
        annotationView?.canShowCallout = true
        
        
        return annotationView
    }
}
