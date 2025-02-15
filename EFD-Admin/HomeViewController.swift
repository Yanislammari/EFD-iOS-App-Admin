//
//  HomeViewController.swift
//  EFD-Admin
//
//  Created by Yanis Lammari on 22/01/2025.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var emailValue: UITextField!
    
    @IBOutlet weak var passwordValue: UITextField!
    
    @IBOutlet weak var errorMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorMessage.text = ""
    }
    
    @IBAction func connexion(_ sender: UIButton) {
        let url = URL(string: "http://127.0.0.1:3000/admin/login")!
        let body = ["email":emailValue.text!,"password":passwordValue.text!]
        
        guard let JSONbody = try? JSONSerialization.data(withJSONObject: body, options: []) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = JSONbody
        
        let task = URLSession.shared.dataTask(with: request) { data, response, err in
            guard err == nil else{ return}
            guard let dataIsNotNil = data else { return }
            
            guard let json = try? JSONSerialization.jsonObject(with: dataIsNotNil) else { return }
            
            guard let httpResponse = response as? HTTPURLResponse,(200...299).contains(httpResponse.statusCode) else {
                let answer = json as? [String : String]
                
                DispatchQueue.main.async{
                    self.errorMessage.text = answer?["message"]
                }
                return
            }
            
            guard let answerSuccess = json as? [String : String] else { return }
            
            DispatchQueue.main.async{
              
                
                if let token = answerSuccess["token"] {
                    let appdelegate = UIApplication.shared.delegate as! AppDelegate
                    appdelegate.token = token  
                    
                    self.navigationController?.pushViewController(AccueilViewController.newInstance(), animated: true)
                }

            }
        }
        task.resume()
    }
    
     func deconnexion() {
         DispatchQueue.main.async {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.token = nil
                }

                let loginVC = HomeViewController(nibName: "HomeViewController", bundle: nil)
                let navigationController = UINavigationController(rootViewController: loginVC)
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController = navigationController
                    window.makeKeyAndVisible()
                }
            }
    }

    
}
