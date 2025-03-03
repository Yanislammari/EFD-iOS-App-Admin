//
//  DetailDeliveryTourViewController.swift
//  EFD-Admin
//
//  Created by Rishi Balasubramanim on 17/02/2025.
//

import UIKit

class DetailDeliveryTourViewController: UIViewController {
    
    var delivery: Delivery!
    var all: [Delivery] = []
    
    
    @IBOutlet weak var deliveryName: UILabel!
    @IBOutlet weak var bigDescription: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bigDescription.layer.cornerRadius = 10
        bigDescription.layer.masksToBounds = true
        fetchDeliveryDetails()
    }
    
    private func fetchDeliveryDetails() {
        guard let deliveryId = delivery?.delivery_id else {
            return
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let token = appDelegate.token else {
            return
        }
        
        
        let request = request(route: "admin/colis_to_deliver/\(deliveryId)", method: "GET", token: token)
        
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
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                
                if let jsonArray = jsonObject as? [[String: Any]] {
                    
                    let allDeliveries = jsonArray.compactMap { Delivery.fromJSON(dict: $0) }
                    
                    DispatchQueue.main.async {
                        self.all = allDeliveries
                        self.updateUI()
                    }
                    
                } else {
                }
                
            } catch {
            }
        }
        
        task.resume()
    }
    
    
    
    
    
    private func updateUI() {
        guard let delivery = delivery else { return }
        
        let statusText = delivery.status
        let deliverymanInfo = delivery.deliveryman_id != nil ? """
            👤 **Livreur** : \(delivery.deliveryman_id!.name)
            📞 **Téléphone** : \(delivery.deliveryman_id!.first_name)
            """ : "👤 **Aucun livreur assigné**"
        
        deliveryName.text = "Tournée \(delivery.delivery_id)"
        bigDescription.text = """
            🚚 **Statut** : \(statusText)
            🕒 **Créé le** : \(delivery.created_at)
            🔄 **Mis à jour le** : \(delivery.updated_at)
            \(deliverymanInfo)
            """
    }
    
    static func newInstance(delivery: Delivery) -> DetailDeliveryTourViewController {
        let detailVC = DetailDeliveryTourViewController()
        detailVC.delivery = delivery
        return detailVC
    }
    
    @IBAction private func deleteDelivery(_ sender: Any) {
        guard let deliveryId = delivery?.delivery_id else {
            return
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let token = appDelegate.token else {
            return
        }
        
        
        let request = request(route: "admin/livraison/\(deliveryId)", method: "DELETE", token: token)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return
            }
            
            if httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
            }
        }
        
        task.resume()
    }
    
    @IBAction private func patchDelivery(_ sender: Any) {
        //  let modifyVC = ModifyDeliveryTourViewController.newInstance(delivery: delivery)
        // reloadVC(next: modifyVC, actu: self)
    }
    
    @IBAction private func createDelivery(_ sender: Any) {
        reloadVC(next: AddDeliveryTourViewController(), actu: self)
    }
}
