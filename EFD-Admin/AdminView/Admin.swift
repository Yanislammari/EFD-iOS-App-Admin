//
//  Admin.swift
//  EFD-Admin
//
//  Created by Rishi Balasubramanim on 04/02/2025.
//

import Foundation

class Admin {
    
    var uuid: String
    var email: String
    var passsword: String
    var createdAt: String
    var updatedAt: String
    
    init(uuid: String, email: String, passsword: String, createdAt: String, updatedAt: String) {
        self.uuid = uuid
        self.email = email
        self.passsword = passsword
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    static func fromJSON(dict: [String: Any]) -> Admin? {
        guard let uuid = dict["uuid"] as? String,
              let email = dict["email"] as? String,
              let passsword = dict["password"] as? String,
              let createdAt = dict["created_at"] as? String,
              let updatedAt = dict["updated_at"] as? String
        else {
            return nil
        }
        
        return Admin(uuid: uuid, email: email, passsword: passsword, createdAt: createdAt, updatedAt: updatedAt)
    }
    
    
}
