//
//  DailyWeather.swift
//  
//
//  Created by Mattia Fochesato on 29/03/22.
//

import Foundation
import Vapor

/**
 Get the daily weather from OpenWeatherMap
 
 - parameters:
  - lat: Latitude
  - lon: Longitude
 - returns: `DailyWeather` object
 */
func getDailyForecast(lat: Double, lon: Double) async throws -> DailyWeather {
    /// Get the API Key from Environment Variables
    guard let apiKey = Environment.get("OWM_KEY") else {
        /// Throws an error if the API Key is not set
        throw WeatherFetchError.apiKeyNotSet
    }
    /// Create the URL for the API call
    let url = URL(string: "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&appid=\(apiKey)")!
    ///  Use URLSession to get the data from the API endpoint
    let (data, _) = try await URLSession.shared.data(from: url)
    /// Decode the JSON, serialize it in a `DailyWeather` object and return it
    return try JSONDecoder().decode(DailyWeather.self, from: data)
}

/** Root of the JSON file  */
struct DailyWeather: Codable {
    /// Status code
    let cod: Int
    /// Optional error message
    let message: String?
    /// Information about the current city
    let city: DailyWeatherCity?
    /// The forecast
    let list: [DailyWeatherItem]?
    
    /** Returns the error if set */
    func error() -> String? {
        if cod != 200 {
            return message ?? "Error code: \(cod)"
        }
        
        return nil
    }
    
    /// Since the APIs are not well made to support Swift encoding, we have to check manually.. todo
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        /// The API sometimes can return a string as "cod". It happens only when cod is "200".
        let tmpCod = try? values.decode(Int.self, forKey: .cod)
        self.cod = tmpCod ?? 200
        
        /// Optional: may not be set
        message = try? values.decode(String.self, forKey: .message)
        
        /// Decode the rest of the JSON file
        city = try? values.decode(DailyWeatherCity.self, forKey: .city)
        list = try? values.decode([DailyWeatherItem].self, forKey: .list)
    }
}

/** Information about the city */
struct DailyWeatherCity: Codable {
    let name: String
    let country: String
    /// Sunset timestamp
    let sunset: Int
    /// Sunride timestamp
    let sunrise: Int
}

/** Weather conditions item */
struct DailyWeatherItem: Codable {
    /// Timestamp of the forecast
    let dt: Int
    /// The weather condition
    let weather: [WeatherCondition]?
    /// Temperature information
    let main: CurrentWeatherTemperature?
    /// Wind information
    let wind: CurrentWindCondition?
    /// Visibility
    let visibility: Int?
}
