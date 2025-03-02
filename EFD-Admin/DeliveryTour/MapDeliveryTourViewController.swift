//
//  MapDeliveryTourViewController.swift
//  EFD-Admin
//
//  Created by Rishi Balasubramanim on 02/03/2025.
//

import UIKit
import MapKit
import CoreLocation

class MapDeliveryTourViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var deliveryMan: [Deliver] = [] {
        didSet {
            self.reloadMap()
        }
    }
    
    var locationManager: CLLocationManager!
    
    var updateTimer: Timer?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initLocations()
        self.mapView.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchDeliver()
        updateTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(fetchDeliver), userInfo: nil, repeats: true)

        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateTimer?.invalidate()
    }
    
    @objc func fetchDeliver() {
        
        
        
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let token = appDelegate.token else {
            print("❌ Aucun token disponible. L'utilisateur doit se reconnecter.")
            return
        }
        
        
        
        let request = request(route: "admin/delivery_man", method: "GET",token: token)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("❌ Erreur réseau : \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("❌ Aucune donnée reçue")
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📥 Réponse JSON brute : \(jsonString)")
            }
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                
                if let jsonArray = jsonObject as? [[String: Any]] {
                    
                    let allDeliveries = jsonArray.compactMap { Deliver.fromJSON(dict: $0) }
                    
                    DispatchQueue.main.async {
                        self.deliveryMan = allDeliveries
                    }
                    
                } else {
                    print("❌ Erreur : L'API ne retourne pas un tableau mais \(type(of: jsonObject))")
                }
                
            } catch {
                print("❌ Erreur de parsing JSON : \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    func initLocations() {
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        if self.locationManager.authorizationStatus == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        }
        
    }
    
  
    
    func reloadMap() {
        DispatchQueue.main.async {
            self.mapView.removeAnnotations(self.mapView.annotations)

            var newAnnotations: [MKPointAnnotation] = []
            
            for dm in self.deliveryMan {
                let newAnnotation = MKPointAnnotation()
                newAnnotation.title = dm.name
                newAnnotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(dm.lat), longitude: CLLocationDegrees(dm.lng))
                newAnnotations.append(newAnnotation)
            }
            
            self.mapView.addAnnotations(newAnnotations)
            self.mapView.showAnnotations(newAnnotations, animated: true)
        }
    }

    
}


extension MapDeliveryTourViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard
            let annotationCoordinate = view.annotation?.coordinate,
            let userLocation = mapView.userLocation.location
        else {
            return
        }
        let annotationLocation = CLLocation(latitude: annotationCoordinate.latitude, longitude: annotationCoordinate.longitude)
        let distance = annotationLocation.distance(from: userLocation)
        print(distance)
    }
}

extension MapDeliveryTourViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    }
}
