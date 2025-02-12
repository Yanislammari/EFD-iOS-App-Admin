//
//  API.swift
//  EFD-Admin
//
//  Created by Rishi Balasubramanim on 04/02/2025.
//

import Foundation
import UIKit



func request(route: String, method: String, token: String? = nil, body: [String: Any]? = nil) -> URLRequest {
    var request = URLRequest(url: URL(string: "http://127.0.0.1:3000/\(route)")!)
    request.httpMethod = method
    
    if let token = token {
        request.setValue("BEARER \(token)", forHTTPHeaderField: "Authorization")
    }
    
    if let body = body {
        let jsonBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        request.httpBody = jsonBody
    }
    
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    return request
}


