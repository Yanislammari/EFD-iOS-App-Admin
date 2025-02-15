//
//  SplitScreenManager.swift
//  EFD-Admin
//
//  Created by Rishi Balasubramanim on 15/02/2025.
//

import Foundation
import UIKit

func createVC(goTo:UIViewController,actu:UIViewController){
    let splitVC = UISplitViewController()
    
    splitVC.viewControllers = [goTo,UIViewController()]
    
    let tabBarControl = UITabBarController()

    tabBarControl.viewControllers = [
        splitVC,
    ]
    
    tabBarControl.navigationItem.hidesBackButton = true
    
    actu.navigationController?.pushViewController(tabBarControl, animated: true)
}


func createTwoScreensVC(goTo:UIViewController,secondGoTo:UIViewController, actu:UIViewController){
    let splitVC = UISplitViewController()
    
    splitVC.viewControllers = [goTo,secondGoTo]
    
    let tabBarControl = UITabBarController()

    tabBarControl.viewControllers = [
        splitVC,
    ]
    
    tabBarControl.navigationItem.hidesBackButton = true
    
    actu.navigationController?.pushViewController(tabBarControl, animated: true)
}


func reloadVC(next:UIViewController,actu:UIViewController){
    if actu.splitViewController != nil {
        actu.splitViewController!.viewControllers[1] = next
    }
    else if actu.navigationController != nil {
        actu.navigationController?.pushViewController(next, animated: true)
    }
}

func goToSplitFromNavBar(goTo:UIViewController,name:String,image:UIImage?,selectedImage:UIImage?)->UINavigationController{
    let splitVC = UISplitViewController()
    
    splitVC.viewControllers = [goTo,UIViewController()]
    
    let tabBarControl = UITabBarController()

    tabBarControl.viewControllers = [
        splitVC,
    ]
    
    let bottomBarIcon = UINavigationController(rootViewController: tabBarControl)
    let  iconManagement = UITabBarItem(title: name, image: image, selectedImage: selectedImage)
    iconManagement.imageInsets = UIEdgeInsets(top: -6, left: 0, bottom: 6, right: 0)
    iconManagement.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -16)
    
    bottomBarIcon.tabBarItem = iconManagement
    
    return bottomBarIcon
}
