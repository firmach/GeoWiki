//
//  WikiUrl.swift
//  WikiLocations
//
//  Created by Roman Churkin on 31/05/2023.
//

import Foundation
import  CoreLocation


typealias WikiUrl = URL


extension WikiUrl {
    init?(coordinate: CLLocationCoordinate2D) {
        let scheme = "wikipedia-official"
        let path = "/places"
        let queryItems = [URLQueryItem(name: "lat", value: "\(coordinate.latitude)"),
                          URLQueryItem(name: "lon", value: "\(coordinate.longitude)")]

        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = ""
        urlComponents.path = path
        urlComponents.queryItems = queryItems

        /*
         This fix needed because when the host is nil, it will result in `wikipedia-official:/places`
         and when the host is empty, it will result in `wikipedia-official:///places`.
         */
        guard let rawUrl = urlComponents.string?.replacingOccurrences(of: "///", with: "//") else { return nil }

        self.init(string: rawUrl)
    }
}
