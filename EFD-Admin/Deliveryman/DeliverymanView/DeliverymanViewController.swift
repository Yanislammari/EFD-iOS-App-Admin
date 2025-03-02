//
//  DeliverymanViewController.swift
//  EFD-Admin
//
//  Created by Rishi Balasubramanim on 15/02/2025.
//

import UIKit

class DeliverymanViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{
    
    var all: [Deliver] = []
    
    @IBOutlet weak var deliverTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib = UINib(nibName: "GetDeliverymanViewCell", bundle: nil)
        self.deliverTableView.register(cellNib, forCellReuseIdentifier: "DELIVERY_CELL_ID")
        
        self.deliverTableView.dataSource = self
        self.deliverTableView.delegate = self
        
        fetchDeliver()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.all.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let deliveryman = self.all[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DELIVERY_CELL_ID", for: indexPath) as! DeliverymanTableViewCell
        
        cell.reload(with: deliveryman)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let next = DetailDeliveryViewController.newInstance(deliver: self.all[indexPath.row])
        
        reloadVC(next: next, actu: self)
    }
    
    func fetchDeliver() {
        
        
        
        
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
                        self.all = allDeliveries
                        self.deliverTableView.reloadData()
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchDeliver()
    }
    
    

}
