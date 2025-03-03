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
    var adress: Address?
    var status: String
    var lgt: Float
    var lat : Float
    var created_at: String
    var updated_at: String
    
    init(parcel_id: String, destination_name: String, adress_id: String,adress: Address?, status: String, lgt: Float, lat: Float, created_at: String, updated_at: String) {
        self.parcel_id = parcel_id
        self.destination_name = destination_name
        self.adress_id = adress_id
        self.adress = adress
        self.status = status
        self.lgt = lgt
        self.lat = lat
        self.created_at = created_at
        self.updated_at = updated_at
    }
    
    static func fromJSON(dict: [String:Any]) -> Parcel? {
        guard let parcel_id = dict["uuid"] as? String,
              let destination_name = dict["destination_name"] as? String,
              let adress_id = dict["adress_id"] as? String,
              let status = dict["status"] as? String,
              let created_at = dict["created_at"] as? String,
              let updated_at = dict["updated_at"] as? String
        else {
            return nil
        }
        
        let lat: Float = {
                if let latValue = dict["lat"] as? Double {
                    return Float(latValue)
                } else if let latValue = dict["lat"] as? NSNumber {
                    return latValue.floatValue
                } else if let latString = dict["lat"] as? String, let latDouble = Double(latString) {
                    return Float(latDouble)
                } else {
                    return 0.0
                }
            }()

            let lgt: Float = {
                if let lgtValue = dict["lgt"] as? Double {
                    return Float(lgtValue)
                } else if let lgtValue = dict["lgt"] as? NSNumber {
                    return lgtValue.floatValue
                } else if let lgtString = dict["lgt"] as? String, let lgtDouble = Double(lgtString) {
                    return Float(lgtDouble)
                } else {
                    return 0.0
                }
            }()

        
        let adress: Address? = {
                    if let adressDict = dict["adress"] as? [String: Any] {
                        return Address.fromJSON(dict: adressDict)
                    }
                    return nil
                }()
                
        return Parcel(parcel_id: parcel_id, destination_name: destination_name, adress_id: adress_id, adress: adress, status: status, lgt: lgt, lat: lat, created_at: created_at, updated_at: updated_at)
        
        
    }
    
}
