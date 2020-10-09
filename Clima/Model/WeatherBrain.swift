import Foundation
import CoreLocation

protocol WeatherBrainDelegate {
    func didUpdateWeather(_ weatherBrain: WeatherBrain,weather: WeatherModel)
    func didFailWithError(_ error: Error)
}

struct WeatherBrain {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=380b8ff14a1fd5b1f56d9b752a2e1fb4&units=metric" // do not forget to put https
    
    var delegate: WeatherBrainDelegate?
    
    func getWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)" //no space
        performRequest(urlString)
    }
    
    func getWeather(_ lat: CLLocationDegrees,_ lon: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(lat)&lon=\(lon)"
        performRequest(urlString)
    }
    
    func performRequest(_ urlString: String) {
        //1. Creating a url
        if let url = URL(string: urlString) {
            //2. Create a url session
            let session = URLSession(configuration: .default)
            //3. Give the session a task
            let task = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in //closure is used
                if error != nil {
                    self.delegate?.didFailWithError(error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self,weather: weather)
                    }
                }
            }
            //4. Start the task
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
           let decodedData =  try decoder.decode(WeatherData.self, from: weatherData)
            let temp = decodedData.main.temp
            let city = decodedData.name
            let id = decodedData.weather[0].id
            let weatherModel = WeatherModel(conditionID: id, cityName: city, temperature: temp)
            return weatherModel
        } catch  {
            delegate?.didFailWithError(error)
            return nil
        }
       
    }
    
    
   
}
    
