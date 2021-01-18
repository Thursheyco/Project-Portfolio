//
//  WeatherController.swift
//  Skatebud
//
//  Created by JAROD SMITH on 1/5/21.
//

import Foundation
import CoreLocation
import UIKit

class WeatherController: UIViewController, CLLocationManagerDelegate{
    
    //from app
    @IBOutlet weak var tempText: UILabel!
    @IBOutlet weak var suggestionText: UITextView!
    @IBOutlet weak var descText: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    
    //gps variables
    var gpsManager = CLLocationManager()
    var gpsLocation: CLLocation!
    var lat = 0.0
    var lon = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("weather opened")
        let hasInternet = Helper.checkInternetConnection()
        print(hasInternet)
        if hasInternet == false {
            let alert = UIAlertController(title: "ALERT", message: "Internet is required", preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
        }
        
        setupGPS()
    }
    
    func setupGPS(){
        print("setup gps")
        self.gpsManager.requestAlwaysAuthorization()
        self.gpsManager.requestWhenInUseAuthorization()
        if(CLLocationManager.locationServicesEnabled()){
            gpsLocation = gpsManager.location
            gpsManager.delegate = self
            gpsManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            gpsManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let gpsValues: CLLocationCoordinate2D = gpsManager.location?.coordinate
        else {return}
        lat = gpsValues.latitude
        lon = gpsValues.longitude
        if lat == 0 && lon == 0{
            let alert = UIAlertController(title: "ALERT", message: "GPS access is required", preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
        }
        downloadJSON()
    }
    
    func downloadJSON(){
        let urlSession = URLSession(configuration: URLSessionConfiguration.default)
        if let jsonURL = URL(string: "http://api.openweathermap.org/data/2.5/weather?units=imperial&lat=\(lat)&lon=\(lon)&appid=f641a26b765a92243554f877a308aa55"){
            let dataTask = urlSession.dataTask(with: jsonURL) { (data, response, error) in
                if error != nil {print(error ?? "error"); return}
                guard let urlResponsee = response as? HTTPURLResponse, urlResponsee.statusCode == 200
                else{return}
                do{
                    let obj = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String:Any]
                    self.parseJSON(json: obj)
                }catch{
                    print(error.localizedDescription)
                }
            }
            dataTask.resume()
        }
    }
    
    
    func parseJSON(json:[String:Any]){
        var id = 0.0
        var weatherType = ""
        var weatherDetail = ""
        var icon = ""
        var temp = 0.0
        var feels_like = 0.0
        var temp_min = 0.0
        var temp_max = 0.0
        var humidity = 0.0
        
        var windSpeed = 0.0
        
        var currentTime = 0.0
        var sunrise = 0.0
        var sunset = 0.0
        
        let weather = (json["weather"] as? Array<Dictionary<String, Any>>)!
        for t in weather{
            id = (t["id"] as? Double)!
            weatherType = (t["main"] as? String)!
            weatherDetail = (t["description"] as? String)!
            icon = (t["icon"] as? String)!
        }
        
        let main = (json["main"] as? [String: Any])!
        temp = (main["temp"] as? Double)!
        feels_like = (main["feels_like"] as? Double)!
        temp_min = (main["temp_min"] as? Double)!
        temp_max = (main["temp_max"] as? Double)!
        humidity = (main["humidity"] as? Double)!
                
        let wind = (json["wind"] as? [String: Any])!
        windSpeed = (wind["speed"] as? Double)!
        
        currentTime = (json["dt"] as? Double)!

        let sys = (json["sys"] as? [String: Any])!
        sunrise = (sys["sunrise"] as? Double)!
        sunset = (sys["sunset"] as? Double)!
        
        // UPDATE FIELDS
        DispatchQueue.main.async {
            guard let iconURL = URL(string: "http://openweathermap.org/img/wn/"+icon+"@2x.png") else {return}
            DispatchQueue.global().async {
                guard let data = try? Data(contentsOf: iconURL) else {return}
                let iconImage = UIImage(data: data)
                DispatchQueue.main.async {
                    self.weatherImage.image = iconImage
                }
            }
            self.tempText.text = String(temp) + "°F"
            
            self.descText.text = weatherType + ": "+weatherDetail
            var suggestion = ""
            if temp < 32 {
                suggestion = suggestion + "It's too cold, you should stay in."
                self.suggestionText.text = suggestion
                return
            }
            if temp > 104 {
                suggestion = suggestion + "It's too hot, you should stay in."
                self.suggestionText.text = suggestion
                return
            }
            if windSpeed > 39 {
                suggestion = suggestion + "It may be too windy today."
                self.suggestionText.text = suggestion
                return
            }
            if id <= 799 {
                suggestion = suggestion + "The weather is bad, stay in."
                self.suggestionText.text = suggestion
                return
            }
            
            suggestion = suggestion + "It feels like it's " + String(feels_like) + "°F"
            suggestion = suggestion + ", the humidity is " + String(humidity) + "%"
            var isDay = false
            if currentTime > sunrise && currentTime < sunset {
                isDay = true
            }
            if isDay == false {
                suggestion = suggestion + "\nIt's dark out, make sure to have some light"
            }
            
            self.suggestionText.text = suggestion
            print(temp_min)
            print(temp_max)
            

        }
    }
    
}
