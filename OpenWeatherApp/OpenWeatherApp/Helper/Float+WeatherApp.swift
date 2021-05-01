//
//  Float+WeatherApp.swift
//  OpenWeatherApp
//
//  Created by Sudha Rani on 01/05/21.
//

import Foundation

extension Float {
    
    /// Convert temperature info
    /// - Parameters:
    ///   - temp: temp is a float type
    ///   - inputTempType: provide input to formatter in Unit Temperature type
    ///   - outputTempType: provide output to formatter in Unit Temperature type
    /// - Returns: string type
    func convertToTempString(from inputTempType: UnitTemperature, to outputTempType: UnitTemperature) -> String {
        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.numberFormatter.maximumFractionDigits = 0
        measurementFormatter.unitOptions = .providedUnit
        let input = Measurement(value: Double(self), unit: inputTempType)
        let output = input.converted(to: outputTempType)
        return measurementFormatter.string(from: output)
    }
}
