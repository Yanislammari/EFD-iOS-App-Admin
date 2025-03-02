//
//  AddDeliverymanViewController.swift
//  EFD-Admin
//
//  Created by Rishi Balasubramanim on 01/03/2025.
//

import UIKit

class AddDeliverymanViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var errorName: UILabel!
    var token: String?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorName.text! = ""
        
    }
    
    
    
    @IBAction func handleContinue(_ sender: Any) {
        errorName.text = ""
        
        guard let email = emailTextField.text, !email.isEmpty else {
            errorName.text = "Email is required"
            return
        }
        guard let password = passwordTextField.text, !password.isEmpty else {
            errorName.text = "Password is required"
            return
        }
        guard let phone = phoneTextField.text, !phone.isEmpty else {
            errorName.text = "Phone number is required"
            return
        }
        guard let firstName = firstNameTextField.text, !firstName.isEmpty else {
            errorName.text = "First name is required"
            return
        }
        guard let name = nameTextField.text, !name.isEmpty else {
            errorName.text = "Name is required"
            return
        }
        
        if email.count > 128 {
            errorName.text = "Email is too long"
            return
        }
        if password.count > 128 {
            errorName.text = "Password is too long"
            return
        }
        if phone.count > 128 {
            errorName.text = "Phone number is too long"
            return
        }
        if firstName.count > 128 {
            errorName.text = "First name is too long"
            return
        }
        if name.count > 128 {
            errorName.text = "Name is too long"
            return
        }
        
        if !isValidEmail(email) {
            errorName.text = "Invalid email format"
            return
        }
        
     
        if !isValidPhoneNumber(phone) {
            errorName.text = "Invalid phone number format"
            return
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.token = appDelegate.token
        
        let body: [String: Any] = [
            "email": email,
            "password": password,
            "phone": phone,
            "first_name": firstName,
            "name": name
        ]
        
        let request = request(route: "admin/delivery_man/", method: "POST", token: self.token,body: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, err in
            guard err == nil else {
                DispatchQueue.main.async {
                    self.errorName.text = "Connection error"
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorName.text = "No data received"
                }
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                
                DispatchQueue.main.async {
                    if let responseMessage = json?["message"] as? String {
                        self.errorName.text = responseMessage
                        return
                    }
                    
                    self.showAlert(message: "Deliveryman added successfully") {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorName.text = "Error processing data"
                }
            }
        }
        task.resume()
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPred.evaluate(with: email)
    }
    
    func isValidPhoneNumber(_ phone: String) -> Bool {
        let phoneRegex = "^[0-9]+$"
        let phonePred = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePred.evaluate(with: phone)
    }
    
    func showAlert(message: String, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completion?()
            })
            self.present(alert, animated: true)
        }
    }
    
    
    
    
}

