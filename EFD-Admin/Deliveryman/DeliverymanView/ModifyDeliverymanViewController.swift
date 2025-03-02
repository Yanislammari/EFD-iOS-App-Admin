//
//  ModifyDeliverymanViewController.swift
//  EFD-Admin
//
//  Created by Rishi Balasubramanim on 02/03/2025.
//

import UIKit

class ModifyDeliverymanViewController: UIViewController {
    
    var deliver: Deliver!
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    var token: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }
    
    private func setupView() {
        guard let deliver = deliver else {
            print("❌ Erreur: deliver est nil")
            return }
        
        print("📌 Détails du livreur récupérés :", deliver.first_name)

        emailTextField.text = deliver.email
        passwordTextField.text = ""
        phoneTextField.text = deliver.phone
        firstNameTextField.text = deliver.first_name
        nameTextField.text = deliver.name
        errorLabel.text = ""
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.token = appDelegate.token
    }
    
    
    @IBAction func updateDeliveryman(_ sender: Any) {
        errorLabel.text = ""
        
        guard let email = emailTextField.text, !email.isEmpty else {
            errorLabel.text = "Email is required"
            return
        }
        
        
        
        guard let phone = phoneTextField.text, !phone.isEmpty else {
            errorLabel.text = "Phone number is required"
            return
        }
        guard let firstName = firstNameTextField.text, !firstName.isEmpty else {
            errorLabel.text = "First name is required"
            return
        }
        guard let name = nameTextField.text, !name.isEmpty else {
            errorLabel.text = "Name is required"
            return
        }
        
        
        if !isValidEmail(email) {
            errorLabel.text = "Invalid email format"
            return
        }
        if !isValidPhoneNumber(phone) {
            errorLabel.text = "Invalid phone number format"
            return
        }
        
        var requestBody: [String: Any] = [
            "email": email,
            "phone": phone,
            "first_name": firstName,
            "name": name
        ]
        
        if let password = passwordTextField.text, !password.isEmpty {
            requestBody["password"] = password
        }
        
        let deliverId = deliver.deliver_id
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let token = appDelegate.token else {
            print("❌ Aucun token disponible. L'utilisateur doit se reconnecter.")
            return
        }
        
       
        
        let request = request(route: "admin/delivery_man/\(deliverId)", method: "PATCH", token: token, body: requestBody)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorLabel.text = "Network error: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorLabel.text = "No data received"
                }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    DispatchQueue.main.async {
                        if let message = json["message"] as? String {
                            self.errorLabel.text = message
                        } else {
                            self.showAlert(message: "Deliveryman updated successfully") {
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorLabel.text = "Error processing data"
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
    
    static func newInstance(deliver: Deliver) -> ModifyDeliverymanViewController {
        let modifyVC = ModifyDeliverymanViewController()
        modifyVC.deliver = deliver
        return modifyVC
    }
    
}
