//
//  MylesShoe.swift
//  myles
//
//  Created by Max Rogers on 1/1/24.
//

import Foundation
import Observation


/// A shoe with information on name and mileage
@Observable
class MylesShoe: Identifiable, Codable, Equatable {
    
    /// A UUID for the shoe
    let id: UUID
    /// The shoe name input by the user
    var name: String
    /// The number of miles run on the shoe
    var miles: Double
    /// An array of run ids connected to the shoe
    var runIds: [UUID] = []
    
    init(id: UUID = UUID(), name: String, miles: Double = 0.0) {
        self.id = id
        self.name = name
        self.miles = miles
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, miles, runIds
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        miles = try container.decodeIfPresent(Double.self, forKey: .miles) ?? 0.0
        runIds = try container.decodeIfPresent([UUID].self, forKey: .runIds) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(miles, forKey: .miles)
        try container.encode(runIds, forKey: .runIds)
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
