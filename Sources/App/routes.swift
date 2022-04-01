import Vapor
import Darwin
import Foundation

/** Custom error for missing query arguments in the request */
enum WeatherRequestError {
    /// Missing the latitude argument
    case missingLat
    /// Missing the longitude argument
    case missingLon
}
extension WeatherRequestError: AbortError {
    var reason: String {
        switch self {
        case .missingLat:
            return "Missing 'lat' parameter"
        case .missingLon:
            return "Missing 'lon' parameter"
        }
    }

    var status: HTTPStatus {
        return .badRequest
    }
}

/// Configure Vapor routes
func routes(_ app: Application) throws {
    /// Index route
    app.get { req -> String in
        /// Show a simple page
        return "Welcome to the Weather API! 🌤"
    }
    
    /// `/weather` route
    app.get("weather") { req -> CompleteWeather in
        /// Check if the query contains the `lat` value
        guard let lat = req.query[Double.self, at: "lat"] else {
            throw WeatherRequestError.missingLat
        }
        /// Check if the query contains the `lon` value
        guard let lon = req.query[Double.self, at: "lon"] else {
            throw WeatherRequestError.missingLon
        }
        
        /// Call the `getWeather(lat: Double, lon: Double)` function and wait for completion
        let weatherInfo = try await getWeather(lat: lat, lon: lon)
        /// Return the result of the funcion.
        /// Vapor will automatically convert the `CompleteWeather` object to JSON data since it is `Codable`
        return weatherInfo
    }
}

/**
 Get the forecast from OpenWeatherMap and combines it
 
 - parameters:
     - lat: Latitude
     - lon: Longitude
 - returns: Complete forecast information
 */
func getWeather(lat: Double, lon: Double) async throws  -> CompleteWeather {
    /// Create a TaskGroup that is going to return a `CompleteWeather` object
    return try await withThrowingTaskGroup(of: WeatherFetchType.self) { group -> CompleteWeather in
        
        /// Fetch current weather
        group.addTask {
            /// Call the function to get the current weather from OWM
            let currentWeather = try await getCurrentWeather(lat: lat, lon: lon)
            /// Return the result at completion
            return .current(currentWeather)
        }
        
        /// Fetch daily weather
        group.addTask {
            /// Call the function to get the daily weather from OWM
            let dailyForecast = try await getDailyForecast(lat: lat, lon: lon)
            /// Return the result at completion
            return .daily(dailyForecast)
        }
        
        /// Temporary variables to store the results
        var dailyForecast: DailyWeather?
        var currentWeather: CurrentWeather?
        
        /// Wait for completion of the tasks and then get the results
        for try await weatherData in group {
            switch weatherData {
                /// Save current weather to the `currentWeather` variable
            case .current(let currentWeatherData):
                currentWeather = currentWeatherData
                break
            case .daily(let dailyForecastData):
                /// Save daily forecast to the `dailyForecast` variable
                dailyForecast = dailyForecastData
                break
            }
        }
        
        /// Make sure that all the data has been fetched
        guard let dailyForecast = dailyForecast, let currentWeather = currentWeather else {
            /// If some data is missing, throw an internalServerError
            throw Abort(.internalServerError)
        }
        
        /// Return the `CompleteWeather` object with all the information about the weather
        return try CompleteWeather(currentWeather: currentWeather, dailyWeather: dailyForecast)
    }
}

/// Used to have multiple return type inside a TaskGroup
enum WeatherFetchType {
    /// Current Weather
    case current(CurrentWeather)
    /// Daily forecast
    case daily(DailyWeather)
}
