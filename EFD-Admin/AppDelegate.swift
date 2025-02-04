//
//  AppDelegate.swift
//  EFD-Admin
//
//  Created by Yanis Lammari on 22/01/2025.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var token: String?
    
    
    func bootIpadApp(){
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        let homeNav = UINavigationController(rootViewController: HomeViewController())
        
        window.rootViewController = homeNav
        window.makeKeyAndVisible()
        self.window = window
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.bootIpadApp()
        return true
    }

    
}
