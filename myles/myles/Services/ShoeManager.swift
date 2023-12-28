//
//  ShoeManager.swift
//  myles
//
//  Created by Max Rogers on 12/27/23.
//

import SwiftUI

// TODO Logging

/// Manager for the user's shoe tracking
class ShoeManager: ObservableObject {
    
    /// Standard user defaults
    let userDefaults = UserDefaults.standard

    init() {
        if let savedShoesData = userDefaults.data(forKey: ShoeUserDefaults.shoeStoreKey) {
                let decoder = JSONDecoder()
                if let savedShoes = try? decoder.decode([MylesShoe].self, from: savedShoesData) {
                    shoes = savedShoes
                } else {
                    shoes = []
                }
        } else {
            shoes = []
        }
    }
    
    /// The user's tracked shoes
    @Published private(set) var shoes: [MylesShoe] {
        didSet {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(shoes) {
                userDefaults.set(encoded, forKey: ShoeUserDefaults.shoeStoreKey)
            }
        }
    }
    
    /// Adds a shoe to the user's tracked shoe list
    func addShoe(_ shoe: MylesShoe) {
        var allShoes = shoes
        allShoes.append(shoe)
        shoes = allShoes
    }
    
}

/// User Default Keys
private struct ShoeUserDefaults {
    static let shoeStoreKey = "rogers.max.myles.shoestorekey"
}

/// A shoe with information on name and mileage
class MylesShoe: ObservableObject, Identifiable, Codable {
    
    var id: UUID
    var name: String
    var miles: Int
    
    init(id: UUID = UUID(), name: String, miles: Int) {
        self.id = id
        self.name = name
        self.miles = miles
    }
    
}
