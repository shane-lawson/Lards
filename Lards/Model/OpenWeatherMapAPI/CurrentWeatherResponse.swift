//
//  CurrentWeatherResponse.swift
//  Lards
//
//  Created by Shane Lawson on 5/26/20.
//  Copyright © 2020 Shane Lawson. All rights reserved.
//

import Foundation
 
struct SysObject: Codable {
   let sunrise: Int
   let sunset: Int
}

struct WeatherResponseObject: Codable {
   let id: Int
   let main: String
   let description: String
   let icon: String
}

struct CurrentWeatherResponse: Codable {
   let weather: [WeatherResponseObject]
   let sys: SysObject
}
