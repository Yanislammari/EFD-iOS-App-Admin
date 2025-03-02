//
//  ModifyParcelViewController.swift
//  EFD-Admin
//
//  Created by Rishi Balasubramanim on 02/03/2025.
//

import UIKit
import CoreLocation
import MapKit

class ModifyParcelViewController: UIViewController {
        
    
    var parcel: Parcel!

    
    @IBOutlet weak var destinationNameTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var streetTextField: UITextField!
    @IBOutlet weak var postalCodeTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var livraisonPicker: UIPickerView!
    
    var token: String?
    var livraisons: [Delivery] = []
    var selectedLivraison: Delivery?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        livraisonPicker.delegate = self
        livraisonPicker.dataSource = self
        fetchLivraisons()
        
    }
    
    private func setupView() {
        guard let parcel = parcel else {
            print("❌ Erreur: parcel est nil")
            return
        }
        
        print("📌 Détails du colis récupérés :", parcel.destination_name)
        
        destinationNameTextField.text = parcel.destination_name
        countryTextField.text = parcel.adress?.country
        cityTextField.text = parcel.adress?.city
        streetTextField.text = parcel.adress?.street
        postalCodeTextField.text = parcel.adress?.postal_code
        errorLabel.text = ""
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.token = appDelegate.token
    }
    
    func getCoordinatesFromAddress(address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let error = error {
                print("❌ Erreur de géocodage : \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let location = placemarks?.first?.location else {
                print("❌ Aucune coordonnée trouvée pour l'adresse")
                completion(nil)
                return
            }

            print("✅ Coordonnées trouvées : \(location.coordinate.latitude), \(location.coordinate.longitude)")
            completion(location.coordinate)
        }
    }

    
    private func fetchLivraisons() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let token = appDelegate.token else {
            print("❌ Aucun token disponible.")
            return
        }
        
        print("📡 Requête GET : admin/livraison")
        
        let request = request(route: "admin/livraison", method: "GET", token: token)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("❌ Erreur réseau : \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("❌ Aucune donnée reçue")
                return
            }
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                if let jsonArray = jsonObject as? [[String: Any]] {
                    let allLivraisons = jsonArray.compactMap { Delivery.fromJSON(dict: $0) }
                    DispatchQueue.main.async {
                        self.livraisons = allLivraisons
                        self.livraisonPicker.reloadAllComponents()
                        print("🚚 \(allLivraisons.count) livraisons chargées")
                    }
                } else {
                    print("❌ Erreur JSON : Format non valide")
                }
            } catch {
                print("❌ Erreur parsing JSON : \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    @IBAction func updateParcel(_ sender: Any) {
        errorLabel.text = ""
        
        guard let destinationName = destinationNameTextField.text, !destinationName.isEmpty else {
            errorLabel.text = "Destination name is required"
            return
        }
        
        guard let country = countryTextField.text, !country.isEmpty else {
            errorLabel.text = "Country is required"
            return
        }
        guard let city = cityTextField.text, !city.isEmpty else {
            errorLabel.text = "City is required"
            return
        }
        guard let street = streetTextField.text, !street.isEmpty else {
            errorLabel.text = "Street is required"
            return
        }
        guard let postalCode = postalCodeTextField.text, !postalCode.isEmpty else {
            errorLabel.text = "Postal code is required"
            return
        }
        
        if destinationName.count > 128 {
            errorLabel.text = "Destination name is too long"
            return
        }
        if country.count > 128 {
            errorLabel.text = "Country name is too long"
            return
        }
        if city.count > 128 {
            errorLabel.text = "City name is too long"
            return
        }
        if street.count > 256 {
            errorLabel.text = "Street name is too long"
            return
        }
        if postalCode.count > 56 {
            errorLabel.text = "Postal code is too long"
            return
        }
        
        let requestBody: [String: Any] = [
            "colis": [
                "destination_name": destinationName
            ],
            "adress": [
                "country": country,
                "city": city,
                "street": street,
                "postal_code": postalCode
            ]
        ]
        
        guard let parcelId = parcel?.parcel_id, let token = self.token else {
            errorLabel.text = "Error: Missing data"
            return
        }
        
        print("📤 Envoi de la requête PATCH pour le colis \(parcelId)")
        let request = request(route: "admin/colis/\(parcelId)", method: "PATCH", token: token, body: requestBody)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorLabel.text = "Network error: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorLabel.text = "No data received"
                }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    DispatchQueue.main.async {
                        if let message = json["message"] as? String {
                            self.errorLabel.text = message
                        } else {
                            self.showAlert(message: "Parcel updated successfully") {
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorLabel.text = "Error processing data"
                }
            }
        }
        task.resume()
    }
    
    func showAlert(message: String, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completion?()
            })
            self.present(alert, animated: true)
        }
    }
    
    static func newInstance(parcel: Parcel) -> ModifyParcelViewController {
        let modifyVC = ModifyParcelViewController()
        modifyVC.parcel = parcel
        return modifyVC
    }
}

extension ModifyParcelViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return livraisons.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "Livraison \(livraisons[row].livraison_date)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard livraisons.indices.contains(row) else {
            print("❌ Erreur : Index hors limite")
            return
        }
        
        selectedLivraison = livraisons[row]
        print("✅ Livraison sélectionnée : \(selectedLivraison!.delivery_id)")
    }
}

