//
//  AddParcelViewController.swift
//  EFD-Admin
//
//  Created by Rishi Balasubramanim on 02/03/2025.
//

import UIKit

class AddParcelViewController: UIViewController {
    
    @IBOutlet weak var destinationNameTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var streetTextField: UITextField!
    @IBOutlet weak var postalCodeTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    var token: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.text = ""
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.token = appDelegate.token
        
        print("✅ Token récupéré: \(self.token ?? "Aucun token")")
    }
    
    @IBAction func handleContinue(_ sender: Any) {
        errorLabel.text = ""
        
        // Vérification des champs
        guard let destinationName = destinationNameTextField.text, !destinationName.isEmpty else {
            errorLabel.text = "Destination name is required"
            print("❌ Erreur: Destination name est vide")
            return
        }
        
        guard let country = countryTextField.text, !country.isEmpty else {
            errorLabel.text = "Country is required"
            print("❌ Erreur: Country est vide")
            return
        }
        guard let city = cityTextField.text, !city.isEmpty else {
            errorLabel.text = "City is required"
            print("❌ Erreur: City est vide")
            return
        }
        guard let street = streetTextField.text, !street.isEmpty else {
            errorLabel.text = "Street is required"
            print("❌ Erreur: Street est vide")
            return
        }
        guard let postalCode = postalCodeTextField.text, !postalCode.isEmpty else {
            errorLabel.text = "Postal code is required"
            print("❌ Erreur: Postal code est vide")
            return
        }
        
        // Vérification de la longueur des champs
        if destinationName.count > 128 {
            errorLabel.text = "Destination name is too long"
            print("❌ Erreur: Destination name trop long")
            return
        }
        if country.count > 128 {
            errorLabel.text = "Country name is too long"
            print("❌ Erreur: Country trop long")
            return
        }
        if city.count > 128 {
            errorLabel.text = "City name is too long"
            print("❌ Erreur: City trop long")
            return
        }
        if street.count > 256 {
            errorLabel.text = "Street name is too long"
            print("❌ Erreur: Street trop long")
            return
        }
        if postalCode.count > 56 {
            errorLabel.text = "Postal code is too long"
            print("❌ Erreur: Postal code trop long")
            return
        }
        
        let parcelBody: [String: Any] = [
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
        
        print("📤 Envoi de la requête POST à /admin/colis avec les données: \(parcelBody)")
        
        guard let token = self.token else {
            errorLabel.text = "User is not authenticated"
            print("❌ Erreur: Aucun token disponible")
            return
        }
        
        let request = request(route: "admin/colis", method: "POST", token: token, body: parcelBody)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorLabel.text = "Connection error"
                    print("❌ Erreur réseau: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorLabel.text = "No data received"
                    print("❌ Aucune donnée reçue du serveur")
                }
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📥 Réponse JSON brute: \(jsonString)")
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                
                DispatchQueue.main.async {
                    if let responseMessage = json?["message"] as? String {
                        self.errorLabel.text = responseMessage
                        print("✅ Réponse du serveur: \(responseMessage)")
                        return
                    }
                    
                    self.showAlert(message: "Parcel added successfully") {
                        print("🎉 Parcel ajouté avec succès !")
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorLabel.text = "Error processing data"
                    print("❌ Erreur de parsing JSON: \(error.localizedDescription)")
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
}
