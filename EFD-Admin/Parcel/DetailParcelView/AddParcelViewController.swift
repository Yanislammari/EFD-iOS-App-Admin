//
//  AddParcelViewController.swift
//  EFD-Admin
//
//  Created by Rishi Balasubramanim on 02/03/2025.
//

import UIKit
import MapKit
import CoreLocation

class AddParcelViewController: UIViewController {
    
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
        errorLabel.text = ""
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.token = appDelegate.token
        
        livraisonPicker.delegate = self
        livraisonPicker.dataSource = self
        fetchLivraisons()
        
    }
    
    private func fetchLivraisons() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let token = appDelegate.token else {
            return
        }
        
        
        let request = request(route: "admin/livraison", method: "GET", token: token)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                if let jsonArray = jsonObject as? [[String: Any]] {
                    let allLivraisons = jsonArray.compactMap { Delivery.fromJSON(dict: $0) }
                    DispatchQueue.main.async {
                        self.livraisons = allLivraisons
                        self.livraisonPicker.reloadAllComponents()
                        
                        // Sélection automatique de la première livraison si disponible
                        if !self.livraisons.isEmpty {
                            self.selectedLivraison = self.livraisons[0]
                            self.livraisonPicker.selectRow(0, inComponent: 0, animated: false)
                        }
                    }
                } else {
                }
            } catch {
            }
        }
        
        task.resume()
    }
    
    func getCoordinatesFromAddress(address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let error = error {
                completion(nil)
                return
            }
            
            guard let location = placemarks?.first?.location else {
                completion(nil)
                return
            }
            
            completion(location.coordinate)
        }
    }
    private func sendParcelCreation(requestBody: [String: Any]) {
        guard let token = self.token else {
            errorLabel.text = "Utilisateur non authentifié"
            return
        }
        
        let request = request(route: "admin/colis", method: "POST", token: token, body: requestBody)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorLabel.text = "Erreur réseau : \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorLabel.text = "Aucune donnée reçue"
                }
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                
                DispatchQueue.main.async {
                    if let responseMessage = json?["message"] as? String {
                        self.errorLabel.text = responseMessage
                        return
                    }
                    
                    self.showAlert(message: "Colis ajouté avec succès") {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorLabel.text = "Erreur de traitement des données"
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
    
    
    @IBAction func handleContinue(_ sender: Any) {
        
        errorLabel.text = ""
        
        guard let destinationName = destinationNameTextField.text, !destinationName.isEmpty,
              let country = countryTextField.text, !country.isEmpty,
              let city = cityTextField.text, !city.isEmpty,
              let street = streetTextField.text, !street.isEmpty,
              let postalCode = postalCodeTextField.text, !postalCode.isEmpty else {
            errorLabel.text = "Tous les champs sont obligatoires"
            return
        }
        
        let fullAddress = "\(street), \(postalCode) \(city), \(country)"
        
        getCoordinatesFromAddress(address: fullAddress) { coordinates in
            guard let coordinates = coordinates else {
                DispatchQueue.main.async {
                    self.errorLabel.text = "Adresse invalide, impossible de récupérer les coordonnées"
                }
                return
            }
            
            let parcelBody: [String: Any] = [
                "colis": [
                    "destination_name": destinationName,
                    "lat": coordinates.latitude,
                    "lgt": coordinates.longitude
                ],
                "adress": [
                    "country": country,
                    "city": city,
                    "street": street,
                    "postal_code": postalCode
                ]
            ]
            
            
            self.sendParcelCreation(requestBody: parcelBody)
        }
    }
}












extension AddParcelViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return livraisons.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "Livraison \(livraisons[row].livraison_date)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard livraisons.indices.contains(row) else {
            return
        }
        
        selectedLivraison = livraisons[row]
    }
}

