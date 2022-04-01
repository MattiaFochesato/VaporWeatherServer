//
//  WeatherFetchError.swift
//  
//
//  Created by Mattia Fochesato on 30/03/22.
//

import Foundation

/** Custom errors for this applications  */
enum WeatherFetchError: Error {
    /// Throw this error if the API Key is not set
    case apiKeyNotSet
    /// Throw this error if there is an error while decoding the JSON file
    case decodingError
}
