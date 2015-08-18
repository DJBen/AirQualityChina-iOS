//
//  DataSample.swift
//  PM25
//
//  Created by Ben Lu on 8/4/15.
//  Copyright © 2015 DJ.Ben. All rights reserved.
//

public class DataSample: NSObject {
    
    static let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone(name: "Asia/Shanghai")
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        return formatter
        }()
    
    public let query: Query
    public let city: String
    public internal(set) var station: Station?
    public let timestamp: NSDate?
    
    public internal(set) var SO2: AirQualityParameter?
    public internal(set) var NO2: AirQualityParameter?
    public internal(set) var CO: AirQualityParameter?
    public internal(set) var O3: AirQualityParameter?
    public internal(set) var O3_8h: AirQualityParameter?
    public internal(set) var PM10: AirQualityParameter?
    public internal(set) var PM25: AirQualityParameter?
    public internal(set) var AQI: Int?
    public internal(set) var primaryPollutant: PrimaryPollutant?
    public internal(set) var airQuality: AirQualityRating?
    
    public var isAverageSample: Bool {
        switch query {
        case .AllCityRanking:
            return false
        default:
            break
        }
        return station == nil
    }
    
    public override var description: String {
        let properties: [String: Any?] = [
            "AQI": AQI,
            "PM 10": PM10,
            "PM 2.5": PM25,
            "SO2": SO2,
            "NO2": NO2,
            "CO": CO,
            "O3": O3,
            "O3_8h": O3_8h]
        
        let airQualityItem = airQuality != nil ? ["\(airQuality!)"] : []
        let primaryPollutantItem = primaryPollutant != nil ? ["\(primaryPollutant!)"] : []
        
        return ", ".join(airQualityItem + primaryPollutantItem + properties.filter { (_, value) -> Bool in
            return value != nil
        }.map { (key, value) -> String in
            if let param = value as? AirQualityParameter {
                return "\(key): \(param)"
            } else if let param = value as? Double {
                return "\(key): \(param)"
            } else {
                return "\(key)"
            }
        })
    }
    
    init?(query: Query, dictionary: [String: AnyObject]) {
        self.query = query
        
        guard let timeString = dictionary["time_point"] as? String, city = dictionary["area"] as? String else {
            timestamp = nil
            self.city = ""
            super.init()
            return nil
        }
        
        self.city = city
        timestamp = NSDate.pm25_dateFromString(timeString)!
        
        let parseDict: (dict: [String: AnyObject], field: String) -> AirQualityParameter = { dict, field in
            let field_24h = field + "_24h"
            let value = dict[field] as? Double
            let dayValue = dict[field_24h] as? Double
            let param = AirQualityParameter(currentValue: value!, dayAverageValue: dayValue)
            return param
        }
        
        let field: String
        
        // Extract field
        switch query {
        case .CityPM10(_), .CityNO2(_), .CityO3(_), .CitySO2(_), .CityCO(_), .CityPM2_5(_):
            field = ((query.path as NSString).lastPathComponent as NSString).stringByDeletingPathExtension.lowercaseString
        case .CityAQI(_):
            field = "aqi"
        default:
            field = ""
            break
        }
        
        let field_24h = field + "_24h"
        let value = dictionary[field] as? Double
        let dayValue = dictionary[field_24h] as? Double
        
        // Extract common properties and error checking
        switch query {
        case .CityPM10(_), .CityNO2(_), .CityO3(_), .CitySO2(_), .CityCO(_), .CityPM2_5(_):
            guard dayValue != nil else {
                print("Warning: 24h value missing in \(field), discarding current sample")
                super.init()
                return nil
            }
            fallthrough
        case .CityAQI(_):
            guard value != nil else {
                print("Warning: value missing in \(field), discarding current sample")
                super.init()
                return nil
            }
            fallthrough
        case .CityDetails(_), .StationDetails(_), .AllCityDetails, .AllCityRanking:
            station = Station(dictionary: dictionary)
            primaryPollutant = PrimaryPollutant(APIObject: dictionary["primary_pollutant"])
            let qualityObject = dictionary["quality"]
            guard let airQuality = AirQualityRating.ratingFromAPIObject(APIObject: qualityObject) else {
                print("Error: fail to convert \(qualityObject) to air quality. It is probably a bad sample. Discarded.")
                super.init()
                return nil
            }
            self.airQuality = airQuality
        default:
            super.init()
            return nil
        }
        
        // Extract individual properties
        switch query {
        case .CityPM10(_):
            PM10 = parseDict(dict: dictionary, field: field)
        case .CityPM2_5(_):
            PM25 = parseDict(dict: dictionary, field: field)
        case .CitySO2(_):
            SO2 = parseDict(dict: dictionary, field: field)
        case .CityCO(_):
            CO = parseDict(dict: dictionary, field: field)
        case .CityNO2(_):
            NO2 = parseDict(dict: dictionary, field: field)
        case .CityO3(_):
            O3 = parseDict(dict: dictionary, field: field)
            O3_8h = parseDict(dict: dictionary, field: "\(field)_8h")
        case .CityAQI(_):
            AQI = (dictionary["aqi"] as! Int)
        case .CityDetails(_), .StationDetails(_), .AllCityDetails, .AllCityRanking:
            PM10 = parseDict(dict: dictionary, field: "pm10")
            PM25 = parseDict(dict: dictionary, field: "pm2_5")
            SO2 = parseDict(dict: dictionary, field: "so2")
            NO2 = parseDict(dict: dictionary, field: "no2")
            CO = parseDict(dict: dictionary, field: "co")
            O3 = parseDict(dict: dictionary, field: "o3")
            O3_8h = parseDict(dict: dictionary, field: "o3_8h")
            AQI = (dictionary["aqi"] as! Int)
        default:
            break
        }
        super.init()
    }
    
}

extension NSDate {
    class func pm25_dateFromString(string: String) -> NSDate? {
        return DataSample.dateFormatter.dateFromString(string)
    }
}

