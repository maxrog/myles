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
    
    /// Removes a shoe from the user's tracked shoe list
    func deleteShoe(_ shoe: MylesShoe, from run: MylesRun) {
        var allShoes = shoes
        guard let index = allShoes.firstIndex(of: shoe) else { return }
        allShoes.remove(at: index)
        shoes = allShoes
    }
    
    /// Adds a shoe to a specific run
    func addShoeToRun(_ shoe: MylesShoe, run: MylesRun) {
        var allShoes = shoes
        guard let index = allShoes.firstIndex(of: shoe) else { return }
        let shoeToUpdate = allShoes[index]
        shoeToUpdate.miles += run.distance
        shoeToUpdate.runId = run.id
        allShoes[index] = shoeToUpdate
        shoes = allShoes
    }
    
    
    /// Removes a shoe from a specific run
    func removeShoe(_ shoe: MylesShoe, from run: MylesRun) {
        var allShoes = shoes
        guard let index = allShoes.firstIndex(where: { $0.runId == run.id }) else { return }
        let shoeToUpdate = allShoes[index]
        shoeToUpdate.miles -= run.distance
        shoeToUpdate.runId = nil
        allShoes[index] = shoeToUpdate
        shoes = allShoes
    }
    
    /// Returns an optional shoe connected to a specific run
    func selectedShoe(for run: MylesRun) -> MylesShoe? {
        return shoes.first(where: { $0.runId == run.id })
    }
    
}

/// User Default Keys
private struct ShoeUserDefaults {
    static let shoeStoreKey = "rogers.max.myles.shoestorekey"
}

/// A shoe with information on name and mileage
class MylesShoe: ObservableObject, Identifiable, Codable, Equatable {
    
    var id: UUID
    var name: String
    var miles: Double
    var runId: UUID?
    
    init(id: UUID = UUID(), name: String, miles: Double = 0) {
        self.id = id
        self.name = name
        self.miles = miles
    }
    
    static func == (lhs: MylesShoe, rhs: MylesShoe) -> Bool {
        lhs.id == rhs.id
    }
    
}

extension MylesShoe: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
