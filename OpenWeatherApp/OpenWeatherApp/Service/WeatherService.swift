//
//  WeatherService.swift
//  OpenWeatherApp
//
//  Created by Sudha Rani on 30/04/21.
//

import Foundation
import UIKit
import CoreData

protocol WeatherServiceType {
    func fetchWeatherInfoData(location: String, completion: @escaping (WeatherInfo?, Error?) -> Void)
    func addToFavourite(weatherInfo: WeatherInfo?)
    func fetchFavourites() ->  [WeatherInfo]
    func deleteFavourites(weatherInfo: WeatherInfo?)
}

class WeatherService: WeatherServiceType {
    
    /// Properties
    let httpClient = HTTPRequest()
    
    var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    var context: NSManagedObjectContext {
        return appDelegate.persistentContainer.viewContext
    }
    
    
    /// Fetch weather data from service
    /// - Parameters:
    ///   - location: location is string type
    ///   - completion: completeion handler
    func fetchWeatherInfoData(location: String, completion: @escaping (WeatherInfo?, Error?) -> Void) {
        guard !location.isEmpty else {
            return
        }
        
         var urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(location)&appid=ff36317d16a0f583baec9c054f89817b"
        urlString = urlString.replacingOccurrences(of: " ", with: "%20")
        
        httpClient.getData(urlString: urlString,
                           decodableType: WeatherInfo.self) { [weak self] weatherInfo, error in
            
            DispatchQueue.main.async {
                if error != nil {
                    let weatherInfo = self?.fetchWeatherInfoFromDatabase(placeName: location)
                    completion(weatherInfo, nil)
                } else {
                    self?.update(weatherInfo: weatherInfo)
                    completion(weatherInfo, nil)
                }
            }
        }
    }
    
    
    //MARK: - Core data methods
    
    
    /// Create new record in core data
    /// - Parameter - weatherInfo: weatherinfo type
    /// - Returns: - weatherInfo
    @discardableResult func createNewRecord(weatherInfo: WeatherInfo) -> NSManagedObject? {
        guard let entity = NSEntityDescription.entity(forEntityName: "Weather", in: self.context) else {
            return nil
        }
        let newWeatherInfo = NSManagedObject(entity: entity, insertInto: self.context)
        self.set(weatherInfo: weatherInfo, to: newWeatherInfo)
        return newWeatherInfo
    }
    
    
    /// Fetchs weather info from core data
    /// - Parameter placeName: - place name is string type
    /// - Returns: - Returns Weather Info
    func fetchWeatherInfoFromDatabase(placeName: String) -> WeatherInfo? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Weather")
        request.predicate = NSPredicate(format: "placeName = %@", placeName)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            if let data = result.first as? NSManagedObject {
                return WeatherInfo.init(managedObject: data)
            }
        } catch {
            print("Failed")
        }
        return nil
    }
    
    
    /// Update Weather info record in core data
    /// - Parameter weatherInfo: - Weather Info type
    func update(weatherInfo: WeatherInfo?) {
        guard let weatherInfo = weatherInfo,
              let placeId = weatherInfo.placeId else {
            return
        }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Weather")
        request.predicate = NSPredicate.init(format: "placeId = %d", placeId)
        request.returnsObjectsAsFaults = false
        
        let result = try? context.fetch(request)
        if let data = result?.first as? NSManagedObject {
            self.set(weatherInfo: weatherInfo, to: data)
        } else {
            self.createNewRecord(weatherInfo: weatherInfo)
        }
        
        appDelegate.saveContext()
    }
    
    
    /// Set Weather info objects
    /// - Parameters:
    ///   - weatherInfo: - Weather Info type
    func set(weatherInfo: WeatherInfo, to managedObject: NSManagedObject) {
        managedObject.setValue(weatherInfo.placeId, forKey: "placeId")
        managedObject.setValue(weatherInfo.placeName, forKey: "placeName")
        managedObject.setValue(weatherInfo.longitude, forKey: "longitude")
        managedObject.setValue(weatherInfo.latitude, forKey: "latitude")
        managedObject.setValue(weatherInfo.humidity, forKey: "humidity")
        managedObject.setValue(weatherInfo.feelsLike, forKey: "feelsLike")
        managedObject.setValue(weatherInfo.maxTemp, forKey: "maxTemp")
        managedObject.setValue(weatherInfo.minTemp, forKey: "minTemp")
        managedObject.setValue(weatherInfo.pressure, forKey: "pressure")
        managedObject.setValue(weatherInfo.temperature, forKey: "temperature")
    }
    
    
    /// Add weather info in Favorites table in Core Data
    /// - Parameter weatherInfo: type is Weather Info
    func addToFavourite(weatherInfo: WeatherInfo?) {
        guard let weatherInfo = weatherInfo,
              let placeId = weatherInfo.placeId,
              let entity = NSEntityDescription.entity(forEntityName: "Favourites", in: self.context) else {
            return
        }
        let favourites = NSManagedObject(entity: entity, insertInto: self.context)
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Weather")
        request.predicate = NSPredicate.init(format: "placeId = %d", placeId)
        request.returnsObjectsAsFaults = false
        
        let result = try? context.fetch(request)
        if let data = result?.first as? NSManagedObject {
            favourites.setValue(placeId, forKey: "placeId")
            favourites.setValue(data, forKey: "weather")
        } else {
            let managedObject = self.createNewRecord(weatherInfo: weatherInfo)
            favourites.setValue(placeId, forKey: "placeId")
            favourites.setValue(managedObject, forKey: "weather")
        }
        
        appDelegate.saveContext()
    }
    
    
    /// Fetchs favorites data from core data
    /// - Returns: - return WeatherInfo array
    func fetchFavourites() ->  [WeatherInfo] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Favourites")
        request.returnsObjectsAsFaults = false
        
        let result = try? context.fetch(request)
        let weatherInfos = result?.compactMap({ data -> WeatherInfo? in
            guard let managedObject = data as? NSManagedObject,
                  let weatherObject = managedObject.value(forKey: "weather") as? NSManagedObject
                  else {
                return nil
            }
            
            return WeatherInfo.init(managedObject: weatherObject)
        })
        return weatherInfos ?? []
    }
    
    
    /// Delete Favorite from favorite table in core data
    /// - Parameter weatherInfo: - type WeatherInfo
    func deleteFavourites(weatherInfo: WeatherInfo?) {
        guard let placeId = weatherInfo?.placeId else {
            return
        }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Favourites")
        request.predicate = NSPredicate.init(format: "placeId = %d", placeId)
        request.returnsObjectsAsFaults = false
        
        if let result = try? context.fetch(request) {
            for data in result {
                guard let managedObject = data as? NSManagedObject else {
                    continue
                }
                context.delete(managedObject)
            }
        }
        
        appDelegate.saveContext()
    }
}
