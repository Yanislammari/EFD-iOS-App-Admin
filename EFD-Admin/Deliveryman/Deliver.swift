//
//  Deliver.swift
//  EFD-Admin
//
//  Created by Rishi Balasubramanim on 15/02/2025.
//

import Foundation

class Deliver {
    var deliver_id: String
    var first_name: String
    var name: String
    var phone: String
    var status: String
    var email: String
    var password: String
    var lat: Float
    var lng: Float
    var createdAt: String
    var updatedAt : String
    
    init(deliver_id: String, first_name: String, name: String, phone: String, status: String, email: String, password: String,lat:Float , lng:Float, createdAt: String, updatedAt: String) {
        self.deliver_id = deliver_id
        self.first_name = first_name
        self.name = name
        self.phone = phone
        self.status = status
        self.email = email
        self.password = password
        self.lat = lat
        self.lng = lng
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    static func fromJSON(dict: [String:Any]) -> Deliver? {
        guard let deliver_id = dict["uuid"] as? String,
              let first_name = dict["first_name"] as? String,
              let name = dict["name"] as? String,
              let phone = dict["phone"] as? String,
              let status = dict["status"] as? String,
              let email = dict["email"] as? String,
              let password = dict["password"] as? String,
              let createdAt = dict["created_at"] as? String,
              let updatedAt = dict["updated_at"] as? String
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


        
        return Deliver(deliver_id: deliver_id, first_name: first_name, name: name, phone: phone, status: status, email: email, password: password, lat: lat,lng: lgt,createdAt: createdAt, updatedAt: updatedAt)
    }
}
