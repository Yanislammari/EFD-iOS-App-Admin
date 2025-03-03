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
            return
        }
        
        
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
                    }
                } else {
                }
            } catch {
            }
        }
        
        task.resume()
    }
    
    @IBAction func updateParcel(_ sender: Any) {
        errorLabel.text = ""
                
                guard let destinationName = destinationNameTextField.text, !destinationName.isEmpty,
                      let country = countryTextField.text, !country.isEmpty,
                      let city = cityTextField.text, !city.isEmpty,
                      let street = streetTextField.text, !street.isEmpty,
                      let postalCode = postalCodeTextField.text, !postalCode.isEmpty else {
                    errorLabel.text = "Tous les champs d'adresse sont obligatoires"
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
                    
                    let requestBody: [String: Any] = [
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

                    
                    self.sendParcelUpdate(requestBody: requestBody)
                }
    }
    
    private func sendParcelUpdate(requestBody: [String: Any]) {
          guard let parcelId = parcel?.parcel_id, let token = self.token else {
              errorLabel.text = "Erreur : Données manquantes"
              return
          }
          
          
          let request = request(route: "admin/colis/\(parcelId)", method: "PATCH", token: token, body: requestBody)
          
          let task = URLSession.shared.dataTask(with: request) { data, response, error in
              if let error = error {
                  DispatchQueue.main.async {
                      self.errorLabel.text = "Erreur réseau : \(error.localizedDescription)"
                  }
                  return
              }
              
              guard data != nil else {
                  DispatchQueue.main.async {
                      self.errorLabel.text = "Aucune donnée reçue"
                  }
                  return
              }
              
              DispatchQueue.main.async {
                  self.showAlert(message: "Colis mis à jour avec succès") {
                      self.navigationController?.popViewController(animated: true)
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
            return
        }
        
        selectedLivraison = livraisons[row]
    }
}

