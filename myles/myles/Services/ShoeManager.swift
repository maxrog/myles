//
//  ShoeManager.swift
//  myles
//
//  Created by Max Rogers on 12/27/23.
//

import SwiftUI
import Observation

/*
 TODO migrate from UserDefaults to SwiftData? Make sure migration works for app updates
 */

/// Manager for the user's shoe tracking
@Observable
class ShoeManager {
    
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
    private(set) var shoes: [MylesShoe] {
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
        MylesLogger.log(.action, "Adding shoe \(shoe.name) to store", sender: String(describing: self))
    }
    
    /// Removes a shoe from the user's tracked shoe list
    func deleteShoe(_ shoe: MylesShoe) {
        var allShoes = shoes
        guard let index = allShoes.firstIndex(of: shoe) else { return }
        allShoes.remove(at: index)
        shoes = allShoes
        MylesLogger.log(.action, "Deleting shoe \(shoe.name) from store", sender: String(describing: self))
    }
    
    /// Modifies a shoe at a certain index
    /// - Parameters:
    /// - updatedShoe: The updated shoe value to replace the old one
    /// - index: The index at which to replace the shoe
    func modifyShoe(_ updatedShoe: MylesShoe, at index: Int) {
        guard shoes.indices.contains(index) else {
            MylesLogger.log(.action, "Could not find shoe to delete at index \(index)", sender: String(describing: self))
            return
        }
        var allShoes = shoes
        allShoes[index] = updatedShoe
        shoes = allShoes
        MylesLogger.log(.action, "Modifying index \(index) with new shoe \(updatedShoe.name)", sender: String(describing: self))
    }
    
    /// Removes a shoe from the user's tracked shoe list using provided index
    func deleteShoe(at index: Int) {
        var shoeName: String?
        if shoes.indices.contains(index) {
            shoeName = shoes[index].name
        } else {
            MylesLogger.log(.action, "Could not find shoe to delete at index \(index)", sender: String(describing: self))
        }
        
        var allShoes = shoes
        allShoes.remove(at: index)
        shoes = allShoes
        MylesLogger.log(.action, "Deleting shoe \(shoeName ?? "") from store", sender: String(describing: self))
    }
    
    /// Adds a shoe to a specific run
    func addShoeToRun(_ shoe: MylesShoe, run: MylesRun) {
        var allShoes = shoes
        guard let index = allShoes.firstIndex(of: shoe) else { return }
        let shoeToUpdate = allShoes[index]
        shoeToUpdate.miles += run.distance
        shoeToUpdate.runIds.append(run.id)
        allShoes[index] = shoeToUpdate
        shoes = allShoes
        MylesLogger.log(.action, "Adding shoe \(shoe.name) for run with id \(run.id.uuidString)", sender: String(describing: self))
    }
    
    
    /// Removes a shoe from a specific run
    func removeShoe(_ shoe: MylesShoe, from run: MylesRun) {
        var allShoes = shoes
        guard let index = allShoes.firstIndex(where: { $0.runIds.contains(run.id) }) else { return }
        let shoeToUpdate = allShoes[index]
        shoeToUpdate.miles -= run.distance
        if let idIndex = shoeToUpdate.runIds.firstIndex(where: { $0 == run.id }) {
            shoeToUpdate.runIds.remove(at: idIndex)
        }
        allShoes[index] = shoeToUpdate
        MylesLogger.log(.action, "Removing shoe \(shoe.name) for run with id \(run.id.uuidString)", sender: String(describing: self))
        shoes = allShoes
    }
    
    /// Returns an optional shoe connected to a specific run
    func selectedShoe(for run: MylesRun) -> MylesShoe? {
        let matchingShoe = shoes.first(where: { $0.runIds.contains(run.id) })
        if let shoe = matchingShoe {
            MylesLogger.log(.action, "Returning matching shoe \(shoe.name) for id: \(run.id)", sender: String(describing: self))
        } else {
            MylesLogger.log(.action, "Could not find matching shoe for id \(run.id)", sender: String(describing: self))
        }
        return matchingShoe
    }
    
}

/// User Default Keys
private struct ShoeUserDefaults {
    static let shoeStoreKey = "rogers.max.myles.shoestorekey"
}
