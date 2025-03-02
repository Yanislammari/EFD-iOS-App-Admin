//
//  ParcelViewController.swift
//  EFD-Admin
//
//  Created by Rishi Balasubramanim on 16/02/2025.
//

import UIKit

class ParcelViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    var all: [Parcel] = []

    @IBOutlet weak var parcelTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib = UINib(nibName: "ParcelTableViewCell", bundle: nil)
        self.parcelTableView.register(cellNib, forCellReuseIdentifier: "PARCEL_CELL_ID")
        self.parcelTableView.dataSource = self
        self.parcelTableView.delegate = self
        
        fetchParcel()

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.all.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let parcel = self.all[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PARCEL_CELL_ID", for: indexPath) as! ParcelTableViewCell
        
        cell.reload(with: parcel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let next = DetailParcelViewController.newInstance(parcel: self.all[indexPath.row])
        
        reloadVC(next: next, actu: self)
    }
    
    
    func fetchParcel() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let token = appDelegate.token else { return }
        
        let request = request(route: "admin/colis", method: "GET", token: token)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                return
            }
            
            guard let data = data else {
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print(jsonString)
            }
            
            do{
                let jsonObject = try JSONSerialization.jsonObject(with: data,options: [])
                
                if let jsonArray = jsonObject as? [[String:Any]] {
                    let allParcels = jsonArray.compactMap{ Parcel.fromJSON(dict: $0) }
                    
                    DispatchQueue.main.async {
                        self.all = allParcels
                        self.parcelTableView.reloadData()
                    }
                    
                } else {
                    
                }
            }catch {
                
            }
        }
        
        task.resume()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchParcel()
    }


   

}
