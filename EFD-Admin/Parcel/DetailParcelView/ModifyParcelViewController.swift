//
//  ModifyParcelViewController.swift
//  EFD-Admin
//
//  Created by Rishi Balasubramanim on 02/03/2025.
//

import UIKit

class ModifyParcelViewController: UIViewController {
    
    var parcel: Parcel!
    
    @IBOutlet weak var destinationNameTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var streetTextField: UITextField!
    @IBOutlet weak var postalCodeTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    var token: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
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
