//
//  WeatherViewModel.swift
//  OpenWeatherApp
//
//  Created by Sudha Rani on 29/04/21.
//

import Foundation

protocol WeatherViewModelType {
    var controller: WeatherViewController? {get set}
    var weatherInfo: WeatherInfo? {get set}
    var minTemperature: String? {get}
    var maxTemperature: String? {get}
    var temparature: String? {get}
    var placeName: String? {get}
    var isCurrentWeatherInfoFav: Bool {get}
    var favourites: [WeatherInfo] {get}

    func fetchWeather(for location: String)
    func deleteFavourite(weather: WeatherInfo?)
    func saveToFavourite(weather: WeatherInfo?)
    func fetchFavourites()

}

class WeatherViewModel: WeatherViewModelType {
        
    /// Property observer for changes in Weather info
    var weatherInfo: WeatherInfo? {
        didSet {
            if self.weatherInfo == nil {return}
            DispatchQueue.main.async {
                self.controller?.configureUI()
                self.changeFavoriteButtonStage()
            }
        }
    }
    
    var isCurrentWeatherInfoFav: Bool {
        return self.favourites.contains { data in
            data.placeId == self.weatherInfo?.placeId
        }
    }
    
    //MARK: - Computed properties
    var favourites: [WeatherInfo] = [] {
        didSet {
            DispatchQueue.main.async {
                self.controller?.configureCollectionView()
                self.changeFavoriteButtonStage()
            }
        }
    }
    
    var minTemperature: String? {
        var minTemp = "L:"
        minTemp += self.weatherInfo?.minTemp?.convertToTempString(from: .kelvin, to: .celsius) ?? "-"
        return minTemp
    }
    
    var maxTemperature: String? {
        var maxTemp = "H:"
        maxTemp += self.weatherInfo?.maxTemp?.convertToTempString(from: .kelvin, to: .celsius) ?? "-"
        return maxTemp
    }
    
    var temparature: String? {
        self.weatherInfo?.temperature?.convertToTempString(from: .kelvin, to: .celsius) ?? "-"
    }
    
    var placeName: String? {
        "\(self.weatherInfo?.placeName ?? "-")"
    }
    
    let weatherService: WeatherServiceType
    
    weak var controller: WeatherViewController?
    
    
    /// Initializer
    /// - Parameter weatherService: type for Weather Service
    init(weatherService: WeatherServiceType = WeatherService()) {
        self.weatherService = weatherService
    }

    
    /// fetch data from Weather API based on location Info
    /// - Parameter location: location is string type (city name)
    func fetchWeather(for location: String) {
        self.weatherService.fetchWeatherInfoData(location: location) { [weak self] weatherInfo, error in
            if error == nil {
                self?.weatherInfo = weatherInfo
            }
        }
    }
    
    //MARK: - Favorites Methods
    
    /// fetch favorties from coredata
    func fetchFavourites() {
        self.favourites = self.weatherService.fetchFavourites()
    }
    
    
    /// Save favorite info in Core Data
    func saveToFavourite(weather: WeatherInfo?) {
        self.weatherService.addToFavourite(weatherInfo: weather)
        self.favourites = self.weatherService.fetchFavourites()
    }
    
    
    /// Delete favorite weather info from Core Data
    /// - Parameter weather: WeatherInfo type
    func deleteFavourite(weather: WeatherInfo?) {
        self.weatherService.deleteFavourites(weatherInfo: weather)
        self.favourites = self.weatherService.fetchFavourites()
    }

    func changeFavoriteButtonStage() {
        if self.isCurrentWeatherInfoFav {
            self.controller?.favoriteButton.isSelected = true
            self.controller?.favoriteButton.tintColor = .systemYellow
        } else {
            self.controller?.favoriteButton.isSelected = false
            self.controller?.favoriteButton.tintColor = .white
        }
    }
}
