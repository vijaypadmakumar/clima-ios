import UIKit
import CoreLocation
import MapKit

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    var weatherBrain = WeatherBrain()
    let locationManager = CLLocationManager()
    var lat: CLLocationDegrees?
    var long: CLLocationDegrees?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()

        weatherBrain.delegate = self
        searchTextField.delegate = self
        
    }
}

//MARK:  - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate {
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        searchTextField.endEditing(true)
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let city = searchTextField.text {
            weatherBrain.getWeather(cityName: city)
        }
        textField.text = ""
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Type something here"
            return false
        }
    }
}

//MARK: - WeatherBrainDelegate

extension WeatherViewController: WeatherBrainDelegate {
    func didUpdateWeather(_ weatherBrain: WeatherBrain,weather: WeatherModel) {
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.getTemperature()
            self.cityLabel.text = weather.cityName
            self.conditionImageView.image = UIImage(systemName: weather.getConditionName())
        }
    }
    
    func didFailWithError(_ error: Error) {
        print(error)
    }
}

//MARK: - CLLocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Got location")
        if let location = locations.last {
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            getCoordinates(lat, lon)
            weatherBrain.getWeather(lat, lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

//MARK: - CurrentLocation button pressed

extension WeatherViewController {
    
    
 
    @IBAction func currentLocationPressed(_ sender: UIButton) {
        if let safeLat = lat, let safeLong = long {
            weatherBrain.getWeather(safeLat, safeLong)
        }
    }
    
    func getCoordinates(_ lat: CLLocationDegrees, _ long: CLLocationDegrees) {
        self.lat = lat
        self.long = long
    }
    
}
