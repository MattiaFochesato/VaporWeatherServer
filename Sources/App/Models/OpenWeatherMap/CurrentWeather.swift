//
//  CurrentWeather.swift
//  
//
//  Created by Mattia Fochesato on 29/03/22.
//

import Foundation
import Vapor

/**
 Get the current weather from OpenWeatherMap
 
 - parameters:
  - lat: Latitude
  - lon: Longitude
 - returns: `CurrentWeather` object
 */
func getCurrentWeather(lat: Double, lon: Double) async throws -> CurrentWeather {
    /// Get the API Key from Environment Variables
    guard let apiKey = Environment.get("OWM_KEY") else {
        /// Throws an error if the API Key is not set
        throw WeatherFetchError.apiKeyNotSet
    }
    /// Create the URL for the API call
    let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)")!
    ///  Use URLSession to get the data from the API endpoint
    let (data, _) = try await URLSession.shared.data(from: url)
    /// Decode the JSON, serialize it in a `CurrentWeather` object and return it
    return try JSONDecoder().decode(CurrentWeather.self, from: data)
}

/** Root of the JSON file
https://openweathermap.org/current */
struct CurrentWeather: Codable {
    /// Current weather condition
    let weather: [WeatherCondition]?
    /// Temperature information
    let main: CurrentWeatherTemperature?
    /// Wind information
    let wind: CurrentWindCondition?
    /// Sunset - Sunrise
    let sys: CurrentSunCondition?
    /// City name
    let name: String?
    /// Status code
    let cod: Int
    /// Optional error message
    let message: String?
    /// Visibility
    let visibility: Int?
    
    /** Returns the error if set */
    func error() -> String? {
        if cod != 200 {
            return message ?? "Error code: \(cod)"
        }
        
        return nil
    }
}

/** Forecast information */
struct WeatherCondition: Codable {
    /// Internal condition id
    let id: Int
    /// Short forecast description
    let main: String
    /// Extended forecast description
    let description: String
    /// Internal forecast icon name
    let icon: String
}

/** Temperature Information */
struct CurrentWeatherTemperature: Codable {
    /// Real temperature
    let temp: Double
    /// Feels Like temperature
    let feels_like: Double
    /// Min temperature
    let temp_min: Double
    /// Max temperature
    let temp_max: Double
    /// Pressure
    let pressure: Int
    /// Humidity
    let humidity: Int
}

/** Wind Information */
struct CurrentWindCondition: Codable {
    /// Wind speed
    let speed: Double
    /// Wind direction
    let deg: Int
}

/** Clouds Information */
struct CurrentCloudCondition: Codable {
    /// Clouds percentage
    let all: Int
}

/** Sunset / Sunrise Information*/
struct CurrentSunCondition: Codable {
    /// Sunrise timestamp
    let sunrise: Int
    /// Sunset timestamp
    let sunset: Int
}
