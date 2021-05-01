//
//  HTTPRequest.swift
//  OpenWeatherApp
//
//  Created by Sudha Rani on 30/04/21.
//

import Foundation

class HTTPRequest {
    
    
    /// Generic method to retrieve the data from service
    /// - Parameters:
    ///   - urlString: - type of String
    ///   - decodableType: Any type of decodable
    ///   - completion: - completion handler
    func getData<T: Decodable>(urlString: String,
                 decodableType: T.Type,
                 completion: @escaping (T?, Error?) -> Void) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
                  (200...204).contains(statusCode) else {
                completion(nil, WeatherErrorInfo.serviceError)
                return
            }
            
            if let data = data,
               let model = try? JSONDecoder().decode(decodableType, from: data) {
                completion(model, nil)
            } else {
                completion(nil, WeatherErrorInfo.decodingError)
            }
        }
        
        task.resume()
    }
}


/// Provide Error type
enum WeatherErrorInfo: Error {
    case serviceError
    case decodingError
}
