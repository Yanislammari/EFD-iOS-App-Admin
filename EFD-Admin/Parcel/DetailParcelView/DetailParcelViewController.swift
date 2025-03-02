//
//  DetailParcelViewController.swift
//  EFD-Admin
//
//  Created by Rishi Balasubramanim on 02/03/2025.
//

import UIKit

class DetailParcelViewController: UIViewController {
    
    var parcel: Parcel!
    
    @IBOutlet weak var parcelName: UILabel!
    @IBOutlet weak var bigDescription: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bigDescription.layer.cornerRadius = 10
        bigDescription.layer.masksToBounds = true
        fetchParcelDetails()
    }
    
    func fetchParcelDetails() {
        guard let parcelId = parcel?.parcel_id else {
            print("❌ Aucun UUID disponible pour ce colis.")
            return
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let token = appDelegate.token else {
            print("❌ Aucun token disponible. L'utilisateur doit se reconnecter.")
            return
        }
        
        let request = request(route: "admin/colis/\(parcelId)", method: "GET", token: token)
        
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
                if let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("✅ JSON après extraction d'un objet :", jsonDict)
                    self.processParcelData(jsonDict)
                } else {
                    print("❌ Erreur : Format JSON inattendu")
                }
            } catch {
                print("❌ Erreur de parsing JSON :", error.localizedDescription)
            }
        }
        
        task.resume()
    }
    
    func processParcelData(_ json: [String: Any]) {
        print("📥 JSON reçu : \(json)")
        print("🔍 Vérification manuelle : lat = \(json["lat"] ?? "❌ Clé absente"), lgt = \(json["lgt"] ?? "❌ Clé absente")")

        if let parcelData = Parcel.fromJSON(dict: json) {
            DispatchQueue.main.async {
                self.parcel = parcelData
                print("🚀 Parcel récupéré avec succès : lat=\(parcelData.lat), lgt=\(parcelData.lgt)")

                self.updateUI()
            }
        } else {
            print("❌ Erreur : Conversion JSON -> Parcel échouée")
        }
    }
    
    func updateUI() {
        guard let parcel = parcel else { return }
        print("parcel ",parcel.lat)
        
        let latString = parcel.lat != 0 ? String(format: "%.3f", parcel.lat) : "Non disponible"
        let lngString = parcel.lgt != 0 ? String(format: "%.3f", parcel.lgt) : "Non disponible"
        
        
        let addressInfo = parcel.adress != nil ? """
            🏠 **Adresse** : \(parcel.adress!.street), \(parcel.adress!.city), \(parcel.adress!.country) - \(parcel.adress!.postal_code)
            """ : "🏠 **Adresse** : Non disponible"
        
        parcelName.text = parcel.destination_name
        bigDescription.text = """
            📦 **Nom du colis** : \(parcel.destination_name)
            🚚 **Statut** : \(parcel.status)
            🌍 **Latitude** : \(latString)
            🌍 **Longitude** : \(lngString)
            🕒 **Créé le** : \(parcel.created_at)
            🔄 **Mis à jour le** : \(parcel.updated_at)
            \(addressInfo)
            """
    }
    
    static func newInstance(parcel: Parcel) -> DetailParcelViewController {
        let detailVC = DetailParcelViewController()
        detailVC.parcel = parcel
        return detailVC
    }
    
    
    @IBAction func deleteParcel(_ sender: Any) {
        guard let parcelId = parcel?.parcel_id else {
            print("❌ Aucun UUID disponible pour ce colis.")
            return
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let token = appDelegate.token else {
            print("❌ Aucun token disponible. L'utilisateur doit se reconnecter.")
            return
        }
        
        let request = request(route: "admin/colis/\(parcelId)", method: "DELETE", token: token)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("❌ Erreur réseau : \(error.localizedDescription)")
                DispatchQueue.main.async {
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Réponse invalide du serveur.")
                DispatchQueue.main.async {
                }
                return
            }
            
            if httpResponse.statusCode == 200 {
                print("✅ Colis supprimé avec succès.")
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
    
    @IBAction func patchParcel(_ sender: Any) {
        let modifyVC = ModifyParcelViewController.newInstance(parcel: parcel)
        reloadVC(next: modifyVC, actu: self)
        
    }
    
    @IBAction func createParcel(_ sender: Any) {
        reloadVC(next: AddParcelViewController(), actu: self)
    }
    
    
}
