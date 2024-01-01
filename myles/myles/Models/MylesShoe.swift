//
//  MylesShoe.swift
//  myles
//
//  Created by Max Rogers on 1/1/24.
//

import Foundation


/// A shoe with information on name and mileage
class MylesShoe: ObservableObject, Identifiable, Codable, Equatable {
    
    /// A UUID for the shoe
    var id: UUID
    /// The shoe name input by the user
    var name: String
    /// The number of miles run on the shoe
    var miles: Double
    /// An array of run ids connected to the shoe
    var runIds: [UUID] = []
    
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
