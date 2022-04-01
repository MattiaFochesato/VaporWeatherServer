//
//  CompleteWeather.swift
//  
//
//  Created by Mattia Fochesato on 29/03/22.
//

import Foundation
import Vapor

/** Root of the JSON that this server is going to return as forecast information  */
struct CompleteWeather: Codable, Content {
    var city: String?
    
    /// Weather information
    var forecast: [CompleteWeatherItem]?
    
    /// Error if present
    var error: Bool = false
    var reason: String?
    
    init(currentWeather: CurrentWeather, dailyWeather: DailyWeather) throws {
        /// Check if `CurrentWeather` has an error
        if let currentWeatherError = currentWeather.error() {
            /// Show the error
            self.error = true
            self.reason = currentWeatherError
            return
        }else {
            forecast = []
            /// Initialize `CompleteWeatherItem` object and add to the forecast list
            forecast?.append(try CompleteWeatherItem(currentWeather: currentWeather))
            /// Set the city name
            self.city = currentWeather.name
        }
        
        /// Check if `DailyWeather` has an error
        if let dailyWeatherError = dailyWeather.error() {
            /// Show the error
            self.error = true
            self.reason = dailyWeatherError
            return
        }else {
            /// Check if the list is present since it is optional
            if let dailyWeatherList = dailyWeather.list {
                /// For each forecast information, decode it and append to the list
                for dw in dailyWeatherList {
                    /// Initialize `CompleteWeatherItem` object and add to the forecast list
                    forecast?.append(try CompleteWeatherItem(dailyWeatherItem: dw))
                }
            }
            
        }
    }
}

/** The object that have all the information about the weather of a given timestamp  */
struct CompleteWeatherItem: Codable {
    /// The timestap of the weather information
    let timestamp: Int
    /// Short description of the weather
    let description: String
    /// OpenWeatherMap icon
    let icon: String
    /// Current temperature in kelvin
    let temperature: Double
    /// Current wind speed
    let windSpeed: Double
    /// Current wind direction
    let windDirection: Int
    
    /** Extract the data from a `CurrentWeather` object  */
    init(currentWeather: CurrentWeather) throws {
        /// Set current timestamp since it is the current weather
        self.timestamp = Int(Date().timeIntervalSince1970)
        
        /// Check if weather description is set
        guard let currentWeatherStrings = currentWeather.weather?.first else {
            throw WeatherFetchError.decodingError
        }
        
        /// Set the weather description and icon
        self.description = currentWeatherStrings.description
        self.icon = currentWeatherStrings.icon
        
        /// Check if the temperature object is set
        guard let currentWeatherTemperature = currentWeather.main else {
            throw WeatherFetchError.decodingError
        }
        
        /// Set the temperature
        self.temperature = currentWeatherTemperature.temp
        
        /// Check if the wind object is set
        guard let currentWeatherWind = currentWeather.wind else {
            throw WeatherFetchError.decodingError
        }
        
        /// Set the wind information
        self.windSpeed = currentWeatherWind.speed
        self.windDirection = currentWeatherWind.deg
        
    }
    
    /** Extract the data from a `DailyWeatherItem` object  */
    init(dailyWeatherItem: DailyWeatherItem) throws {
        /// Set current timestamp since it is the current weather
        self.timestamp = dailyWeatherItem.dt
        
        /// Check if weather description is set
        guard let dailyWeatherStrings = dailyWeatherItem.weather?.first else {
            throw WeatherFetchError.decodingError
        }
        
        /// Set the weather description and icon
        self.description = dailyWeatherStrings.description
        self.icon = dailyWeatherStrings.icon
        
        /// Check if the temperature object is set
        guard let dailyWeatherTemperature = dailyWeatherItem.main else {
            throw WeatherFetchError.decodingError
        }
        
        /// Set the temperature
        self.temperature = dailyWeatherTemperature.temp
        
        /// Check if the wind object is set
        guard let dailyWeatherWind = dailyWeatherItem.wind else {
            throw WeatherFetchError.decodingError
        }
        
        /// Set the wind information
        self.windSpeed = dailyWeatherWind.speed
        self.windDirection = dailyWeatherWind.deg
    }
}
