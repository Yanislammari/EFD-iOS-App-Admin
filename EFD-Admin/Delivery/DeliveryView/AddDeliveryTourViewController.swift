//
//  AddDeliveryTourViewController.swift
//  EFD-Admin
//
//  Created by Rishi Balasubramanim on 02/03/2025.
//

import UIKit

class AddDeliveryTourViewController: UIViewController {
    
    @IBOutlet weak var deliverymanPicker: UIPickerView!
    @IBOutlet weak var colisTableView: UITableView!
    @IBOutlet weak var errorLabel: UILabel!
    
    var token: String?
    var deliverymen: [Deliver] = []
    var colisList: [Parcel] = []
    var selectedDeliveryman: Deliver?
    var selectedColis: Set<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.text = ""

        deliverymanPicker.dataSource = self
        deliverymanPicker.delegate = self
        colisTableView.dataSource = self
        colisTableView.delegate = self
        
        colisTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ParcelCell")

        
        fetchDeliverymen()
        fetchColis()
    }
    
    private func fetchDeliverymen() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let token = appDelegate.token else {
            return
        }
        
        
        let request = request(route: "admin/delivery_man", method: "GET", token: token)
        
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
                    let allDeliverymen = jsonArray.compactMap { Deliver.fromJSON(dict: $0) }
                    DispatchQueue.main.async {
                        self.deliverymen = allDeliverymen
                        self.deliverymanPicker.reloadAllComponents()
                    }
                } else {
                }
            } catch {
            }
        }
        
        task.resume()
    }
    
    private func fetchColis() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let token = appDelegate.token else {
            return
        }
        
        
        let request = request(route: "admin/colis", method: "GET", token: token)
        
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
                    let allColis = jsonArray.compactMap { Parcel.fromJSON(dict: $0) }
                    DispatchQueue.main.async {
                        self.colisList = allColis
                        self.colisTableView.reloadData()
                    }
                } else {
                }
            } catch {
            }
        }
        
        task.resume()
    }
    
    @IBAction func handleSubmit(_ sender: Any) {
        errorLabel.text = ""
        
        guard let selectedDeliveryman = selectedDeliveryman else {
            errorLabel.text = "Sélectionnez un livreur"
            return
        }
        
        if selectedColis.isEmpty {
            errorLabel.text = "Sélectionnez au moins un colis"
            return
        }
        
        let livraisonBody: [String: Any] = [
            "livraison": [
                "deliveryman_id": selectedDeliveryman.deliver_id,
                "livraison_date": "2025-08-17"
            ],
            "colis": Array(selectedColis)
        ]
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let token = appDelegate.token else {
            errorLabel.text = "Utilisateur non authentifié"
            return
        }
        
        let request = request(route: "admin/livraison", method: "POST", token: token, body: livraisonBody)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                DispatchQueue.main.async {
                    self.errorLabel.text = "Erreur de connexion"
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
                    
                    self.showAlert(message: "Tournée ajoutée avec succès") {
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
}

extension AddDeliveryTourViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return deliverymen.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return deliverymen[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedDeliveryman = deliverymen[row]
    }
}

extension AddDeliveryTourViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colisList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParcelCell", for: indexPath)
        let parcel = colisList[indexPath.row]
        cell.textLabel?.text = parcel.destination_name
        cell.accessoryType = selectedColis.contains(parcel.parcel_id) ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let parcel = colisList[indexPath.row]
        if selectedColis.contains(parcel.parcel_id) {
            selectedColis.remove(parcel.parcel_id)
        } else {
            selectedColis.insert(parcel.parcel_id)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
