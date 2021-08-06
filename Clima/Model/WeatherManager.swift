//
//  WeatherManager.swift
//  Clima
//
//  Created by mustafa demiröz on 5.08.2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate{
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    
    func didFailWithError(error: Error)
}


struct WeatherManager {
    
    var delegate: WeatherManagerDelegate?
    
    let weatherUrl = "https://api.openweathermap.org/data/2.5/weather?&appid=08aabfbbfac1a229fafe1d820a649762&units=metric"
    
    func fetchWeather(cityName: String){
        let urlString = "\(weatherUrl)&q=\(cityName)"
        performRequest(urlString: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        let urlString = "\(weatherUrl)&lat=\(latitude)&lon=\(longitude)"
        performRequest(urlString: urlString)
    }
    
    
    
    func performRequest(urlString: String){
        
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            
//            let task = session.dataTask(with: url,completionHandler: handle(data: urlResponse: error:))
            
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error as! Error)
                    return
                }
                else {
                    if let safeData = data {
                        if let weatherModel = parseJson(weatherData: safeData){
                            self.delegate?.didUpdateWeather(self, weather: weatherModel)
                            
                        }
                    }
                }
            }
            
            task.resume()
        }
        
    }
    
    func parseJson(weatherData: Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do {
            let decodedData: WeatherData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weatherModel = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            print (weatherModel.conditionName)
            print(weatherModel.temperatureString)
            return weatherModel
            
        }catch{
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    /*
    func handle (data: Data?, urlResponse: URLResponse?, error: Error?) {
        if error != nil {
            print(error!)
            return
        }
        else {
            if let safeData = data {
                let dataString = String(data: safeData, encoding: .utf8)
                print(dataString)
            }
        }
    }
    */
    
    
    
    
    
    
}
