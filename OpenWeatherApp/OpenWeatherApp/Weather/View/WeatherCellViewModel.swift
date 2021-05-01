//
//  WeatherCellViewModel.swift
//  OpenWeatherApp
//
//  Created by Sudha Rani on 01/05/21.
//

import Foundation


protocol WeatherCellViewModelType {
    var weatherInfo: WeatherInfo {get set}
    var minTemperature: String? {get}
    var maxTemperature: String? {get}
    var temparature: String? {get}
    var placeName: String? {get}

}

class WeatherCellViewModel: WeatherCellViewModelType {
    
    var weatherInfo: WeatherInfo
    
    init(weatherInfo: WeatherInfo) {
        self.weatherInfo = weatherInfo
    }
    
    var minTemperature: String? {
        var minTemp = "L:"
        minTemp += self.weatherInfo.minTemp?.convertToTempString(from: .kelvin, to: .celsius) ?? "-"
        return minTemp
    }
    
    var maxTemperature: String? {
        var maxTemp = "H:"
        maxTemp += self.weatherInfo.maxTemp?.convertToTempString(from: .kelvin, to: .celsius) ?? "-"
        return maxTemp
    }
    
    var temparature: String? {
        self.weatherInfo.temperature?.convertToTempString(from: .kelvin, to: .celsius) ?? "-"
    }
    
    var placeName: String? {
        "\(self.weatherInfo.placeName ?? "-")"
    }
}
