//
//  tabManager.swift
//  EFD-Admin
//
//  Created by Rishi Balasubramanim on 01/03/2025.
//

import Foundation

func getChain(tab:[String])->String{
    let chaine = tab.joined(separator: ",")
    return chaine
}


class storeDeliverymanToAdd {
    static let listDeliveryman = storeDeliverymanToAdd()
    var deliverymanToAdd:[String] = []
    var deliverymanToDelete:[String] = []

    private init(){}
}


