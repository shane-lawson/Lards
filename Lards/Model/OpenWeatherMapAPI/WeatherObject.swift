//
//  WeatherObject.swift
//  Lards
//
//  Created by Shane Lawson on 5/26/20.
//  Copyright © 2020 Shane Lawson. All rights reserved.
//

import Foundation

// esentially a combination of the weather and sys responses to get weather and if day (sunrise/sunset) together

struct WeatherObject {
   let id: Int
   let isDay: Bool
   
   init(id: Int, sunrise: Int, sunset: Int) {
      self.id = id
      let time = Int(Date().timeIntervalSince1970)
      self.isDay = time > sunrise && time < sunset
   }
}
