//
//  OpenWeatherMapAPI.swift
//  Lards
//
//  Created by Shane Lawson on 5/26/20.
//  Copyright © 2020 Shane Lawson. All rights reserved.
//

import CoreLocation
import Foundation

class OpenWeatherMapAPI {
   enum Endpoints {
      case currentWeather(Double, Double)
      
      var stringValue: String {
         switch self {
         case .currentWeather(let lat, let long):
            return "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(long)&appid=\(Auth.key)"
         }
      }
      
      var url: URL {
         return URL(string: self.stringValue)!
      }
   }
   
   struct Auth {
      // pull in API key from untracked Keys.plist so as to keep API key hidden in public repository
      // Keys.plist contains a single dictionary with keys of "key" and "secret" with String value types containing the API key and secret, respectively.
      private struct CodableAuth: Codable {
         let key: String
      }
      
      static let key: String = {
         let path = Bundle.main.path(forResource: "Keys", ofType: "plist")!
         let data = FileManager.default.contents(atPath: path)!
         let apiObject = try! PropertyListDecoder().decode(CodableAuth.self, from: data)
         return apiObject.key
      }()
   }
   
   class func getCurrentWeather(at location: CLLocationCoordinate2D?, completionHandler: @escaping (WeatherObject?, Error?) -> Void) {
      guard let location = location else { print("no location provided"); return }
      let request = URLRequest(url: Endpoints.currentWeather(location.latitude, location.longitude).url)
      URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
         guard let data = data else {
            completionHandler(nil, error)
            return
         }
         
         do {
            let currentWeather = try JSONDecoder().decode(CurrentWeatherResponse.self, from: data)
            
            let weatherObject = WeatherObject(id: currentWeather.weather.first!.id, sunrise: currentWeather.sys.sunrise, sunset: currentWeather.sys.sunset)
            completionHandler(weatherObject, nil)
         } catch {
            completionHandler(nil, error)
         }
         
         }).resume()
   }
}
