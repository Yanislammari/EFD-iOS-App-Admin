//
//  API.swift
//  EFD-Admin
//
//  Created by Rishi Balasubramanim on 04/02/2025.
//

import Foundation
import UIKit

func request(url:String,verb:String)->URLRequest{
    let url = URL(string: "https://127.0.0.1:3000/\(url)")!
    
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    let token = appdelegate.token
    
    
    var request = URLRequest(url: url)
    request.httpMethod = verb
    request.setValue("BEARER \(token!)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    return request
}

func requestWithBody(url:String,verb:String,body:[String:Any])->URLRequest{
    let url = URL(string: "https://127.0.0.1:3000/\(url)")!
    
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    let token = appdelegate.token
    
    
    let JSONbody = try? JSONSerialization.data(withJSONObject:body)
    
    var request = URLRequest(url: url)
    request.httpMethod = verb
    request.setValue("BEARER \(token!)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = JSONbody
    return request
}
