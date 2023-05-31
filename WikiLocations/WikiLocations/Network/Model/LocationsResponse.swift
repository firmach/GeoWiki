//
//  LocationsResponse.swift
//  WikiLocations
//
//  Created by Roman Churkin on 31/05/2023.
//

import Foundation


struct LocationsResponse: Decodable {

    let locations: [Location]

    enum CodingKeys: String, CodingKey {
        case locations
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var locationsContainer = try container.nestedUnkeyedContainer(forKey: .locations)
        var locations = [Location]()
        while !locationsContainer.isAtEnd {
            if let location = try? locationsContainer.decode(Location.self) {
                locations.append(location)
            } else {
                _ = try? locationsContainer.decode(Dummy.self)
            }
        }
        self.locations = locations
    }

    private struct Dummy: Decodable {}

}


struct Location: Decodable, Hashable {

    let name: String?
    let lat: Double
    let long: Double

}
