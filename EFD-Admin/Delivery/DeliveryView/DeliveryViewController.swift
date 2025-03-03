//
//  DeliveryViewController.swift
//  EFD-Admin
//
//  Created by Rishi Balasubramanim on 17/02/2025.
//

import UIKit

class DeliveryViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{
    
    var all: [Delivery] = []
    
    @IBOutlet weak var deliveryTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib = UINib(nibName: "DeliveryTableViewCell", bundle: nil)
        self.deliveryTableView.register(cellNib, forCellReuseIdentifier: "DELIVER_CELL_ID")
        
        self.deliveryTableView.dataSource = self
        self.deliveryTableView.delegate = self
        
        fetchDelivery()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.all.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let delivery = self.all[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "DELIVER_CELL_ID", for: indexPath) as! DeliveryTableViewCell
        
        cell.reload(with: delivery)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let next = DetailDeliveryTourViewController.newInstance(delivery: self.all[indexPath.row])
        
        reloadVC(next: next, actu: self)
        
    }
    
    func fetchDelivery(){
            
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                  let token = appDelegate.token else { return }
            
            let request = request(route: "admin/livraison", method: "GET", token: token)
            
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
                        
                        let allDeliveries = jsonArray.compactMap{Delivery.fromJSON(dict: $0)}
                        
                        DispatchQueue.main.async {
                            self.all = allDeliveries
                            self.deliveryTableView.reloadData()
                        }

                    } else {
                    }
                } catch {
                }
            }
            
            task.resume()
            
        }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchDelivery()
    }
    
    


    

}
