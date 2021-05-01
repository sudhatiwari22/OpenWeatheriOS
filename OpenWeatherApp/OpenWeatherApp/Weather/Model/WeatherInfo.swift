//
//  WeatherModel.swift
//  OpenWeatherApp
//
//  Created by Sudha Rani on 29/04/21.
//

import Foundation
import CoreData

struct WeatherInfo: Codable {
    var placeId: Int?
    var placeName: String?
    var latitude: Double?
    var longitude: Double?
    var temperature: Float?
    var feelsLike: Float?
    var minTemp: Float?
    var maxTemp: Float?
    var pressure: Float?
    var humidity: Float?
    
    
    enum CodingKeys: String, CodingKey {
        case placeId = "id"
        case placeName = "name"
        case coordinate = "coord"
        case main
    }
    
    enum CoordinateCodingKeys: String, CodingKey {
        case longitude = "lon"
        case latitude = "lat"
    }
    
    enum WeatherDetailsCodingKeys: String, CodingKey {
        case temperature = "temp"
        case feelsLike = "feels_like"
        case minTemp = "temp_min"
        case maxTemp = "temp_max"
        case pressure = "pressure"
        case humidity = "humidity"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.placeId = try container.decode(Int.self, forKey: .placeId)
        self.placeName = try? container.decode(String.self, forKey: .placeName)
        
        let coordNestedContainer = try? container.nestedContainer(keyedBy: CoordinateCodingKeys.self, forKey: .coordinate)
        self.longitude = try? coordNestedContainer?.decode(Double.self, forKey: .longitude)
        self.latitude = try? coordNestedContainer?.decode(Double.self, forKey: .latitude)
        
        let weatherNestedContainer = try? container.nestedContainer(keyedBy: WeatherDetailsCodingKeys.self, forKey: .main)
        self.temperature = try? weatherNestedContainer?.decode(Float.self, forKey: .temperature)
        self.feelsLike = try? weatherNestedContainer?.decode(Float.self, forKey: .feelsLike)
        self.minTemp = try? weatherNestedContainer?.decode(Float.self, forKey: .minTemp)
        self.maxTemp = try? weatherNestedContainer?.decode(Float.self, forKey: .maxTemp)
        self.pressure = try? weatherNestedContainer?.decode(Float.self, forKey: .pressure)
        self.humidity = try? weatherNestedContainer?.decode(Float.self, forKey: .humidity)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.placeId, forKey: .placeId)
        try container.encode(self.placeName, forKey: .placeName)
        
        var coordNestedContainer = container.nestedContainer(keyedBy: CoordinateCodingKeys.self, forKey: .coordinate)
        try coordNestedContainer.encode(self.longitude, forKey: .longitude)
        try coordNestedContainer.encode(self.latitude, forKey: .latitude)

        var weatherNestedContainer = container.nestedContainer(keyedBy: WeatherDetailsCodingKeys.self, forKey: .main)
        try weatherNestedContainer.encode(self.temperature, forKey: .temperature)
        try weatherNestedContainer.encode(self.feelsLike, forKey: .feelsLike)
        try weatherNestedContainer.encode(self.minTemp, forKey: .minTemp)
        try weatherNestedContainer.encode(self.maxTemp, forKey: .maxTemp)
        try weatherNestedContainer.encode(self.pressure, forKey: .pressure)
        try weatherNestedContainer.encode(self.humidity, forKey: .humidity)
    }
    
}


extension WeatherInfo {
    init(managedObject: NSManagedObject) {
        self.placeId = managedObject.value(forKey: "placeId") as? Int
        self.placeName = managedObject.value(forKey: "placeName") as? String
        self.longitude = managedObject.value(forKey: "longitude") as? Double
        self.latitude = managedObject.value(forKey: "latitude") as? Double
        self.feelsLike = managedObject.value(forKey: "feelsLike") as? Float
        self.humidity = managedObject.value(forKey: "humidity") as? Float
        self.minTemp = managedObject.value(forKey: "minTemp") as? Float
        self.maxTemp = managedObject.value(forKey: "maxTemp") as? Float
        self.temperature = managedObject.value(forKey: "temperature") as? Float
        self.humidity = managedObject.value(forKey: "humidity") as? Float
    }
}
