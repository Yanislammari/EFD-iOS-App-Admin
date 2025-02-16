//
//  Parcel.swift
//  EFD-Admin
//
//  Created by Rishi Balasubramanim on 16/02/2025.
//

import Foundation

class Parcel {
    var parcel_id: String
    var destination_name: String
    var adress_id: String
    var status: String
    var lgt: Float
    var lat : Float
    var created_at: String
    var updated_at: String
    
    init(parcel_id: String, destination_name: String, adress_id: String, status: String, lgt: Float, lat: Float, created_at: String, updated_at: String) {
        self.parcel_id = parcel_id
        self.destination_name = destination_name
        self.adress_id = adress_id
        self.status = status
        self.lgt = lgt
        self.lat = lat
        self.created_at = created_at
        self.updated_at = updated_at
    }
    
    static func fromJSON(dict: [String:Any]) -> Parcel? {
        guard let parcel_id = dict["parcel_id"] as? String,
              let destination_name = dict["destination_name"] as? String,
              let adress_id = dict["adress_id"] as? String,
              let status = dict["status"] as? String,
              let lgt = dict["lgt"] as? Float,
              let lat = dict["lat"] as? Float,
              let created_at = dict["created_at"] as? String,
              let updated_at = dict["updated_at"] as? String
        else {
            return nil
        }
        
        return Parcel(parcel_id: parcel_id, destination_name: destination_name, adress_id: adress_id, status: status, lgt: lgt, lat: lat, created_at: created_at, updated_at: updated_at)
        
        
    }
    
    
}
