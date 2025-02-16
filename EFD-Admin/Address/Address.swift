//
//  Address.swift
//  EFD-Admin
//
//  Created by Rishi Balasubramanim on 16/02/2025.
//

import Foundation

class Address {
    var address_id: String
    var country: String
    var city: String
    var street: String
    var postal_code: String
    var created_at: String
    var updated_at: String
    
    init(address_id: String, country: String, city: String, street: String, postal_code: String, created_at: String, updated_at: String) {
        self.address_id = address_id
        self.country = country
        self.city = city
        self.street = street
        self.postal_code = postal_code
        self.created_at = created_at
        self.updated_at = updated_at
    }
    
    static func fromJSON(dict: [String:Any]) -> Address? {
        guard let address_id = dict["uuid"] as? String,
              let country = dict["country"] as? String,
              let city = dict["city"] as? String,
              let street = dict["street"] as? String,
              let postal_code = dict["postal_code"] as? String,
              let created_at = dict["created_at"] as? String,
              let updated_at = dict["updated_at"] as? String
        else {
            return nil
        }
        
        return Address(address_id: address_id, country: country, city: city, street: street, postal_code: postal_code, created_at: created_at, updated_at: updated_at)
    }
    
    
}

