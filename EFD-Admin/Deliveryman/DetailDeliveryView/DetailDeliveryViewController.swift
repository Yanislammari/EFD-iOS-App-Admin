//
//  DetailDeliveryViewController.swift
//  EFD-Admin
//
//  Created by Rishi Balasubramanim on 15/02/2025.
//

import UIKit

class DetailDeliveryViewController: UIViewController {
    
    var deliver:Deliver!
    
    @IBOutlet weak var deliverymanName: UILabel!
    
    @IBOutlet weak var bigDescription: UITextView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bigDescription.layer.cornerRadius = 10
        bigDescription.layer.masksToBounds = true
        
        fetchDeliverymanDetails()
    }
    
    func fetchDeliverymanDetails() {
        guard let deliverId = deliver?.deliver_id else {
            return
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let token = appDelegate.token else {
            return
        }
        
        let request = request(route: "admin/delivery_man/\(deliverId)", method: "GET", token: token)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                return
            }
            
            guard let data = data else {
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
            }
            
            do {
                if let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    self.processDeliverymanData(jsonDict)
                } else {
                }
            } catch {
            }
        }
        
        task.resume()
    }
    
    func processDeliverymanData(_ json: [String: Any]) {
        if let deliveryman = Deliver.fromJSON(dict: json) {
            DispatchQueue.main.async {
                self.deliver = deliveryman
                self.updateUI()
            }
        } else {
        }
    }
    
    func updateUI() {
        guard let deliver = deliver else { return }
        
        let latString = deliver.lat != 0 ? "\(deliver.lat)" : "Non disponible"
        let lngString = deliver.lng != 0 ? "\(deliver.lng)" : "Non disponible"
        
        deliverymanName.text = deliver.name
        bigDescription.text = """
            📦 **Nom** : \(deliver.name)
            🏷️ **Prénom** : \(deliver.first_name)
            📞 **Téléphone** : \(deliver.phone)
            📧 **Email** : \(deliver.email)
            🔒 **Mot de passe (haché)** : \(deliver.password)
            🚗 **Statut** : \(deliver.status)
            🌍 **Latitude** : \(latString)
            🌍 **Longitude** : \(lngString)
            🕒 **Créé le** : \(deliver.createdAt)
            🔄 **Mis à jour le** : \(deliver.updatedAt)
            """
    }
    
    static func newInstance(deliver: Deliver) -> DetailDeliveryViewController {
        let detailVC = DetailDeliveryViewController()
        detailVC.deliver = deliver
        return detailVC
    }
    
    @IBAction func createDeliveryman(_ sender: Any) {
        reloadVC(next: AddDeliverymanViewController(), actu: self)
    }
    
    @IBAction func deleteDeliveryman(_ sender: Any) {
        guard let deliverId = deliver?.deliver_id else {
            return
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let token = appDelegate.token else {
            return
        }
        
        let request = request(route: "admin/delivery_man/\(deliverId)", method: "DELETE", token: token)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                }
                return
            }
            
            if httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    
                    self.navigationController?.popViewController(animated: true)
                }
                
            } else {
                DispatchQueue.main.async {
                    
                }
            }
        }
        
        task.resume()
    }
    
    @IBAction func patchDeliveryman(_ sender: Any) {
        let modifyVC = ModifyDeliverymanViewController.newInstance(deliver: deliver)
        reloadVC(next: modifyVC, actu: self)

    }
}

