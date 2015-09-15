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
    public internal(set) var primaryPollutant: Pollutant?
    public internal(set) var airQuality: AirQualityRating?
    
    public var isAverageSample: Bool {
        if let pm25Query = query as? PM25Query {
            switch pm25Query {
            case .AllCityRanking:
                return false
            default:
                break
            }
            return station == nil
        } else {
            return true
        }
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
        
        return (airQualityItem + primaryPollutantItem + properties.filter { (_, value) -> Bool in
            return value != nil
        }.map { (key, value) -> String in
            if let param = value as? AirQualityParameter {
                return "\(key): \(param)"
            } else if let param = value as? Double {
                return "\(key): \(param)"
            } else if let param = value as? Int {
                return "\(key): \(param)"
            } else {
                return "\(key)"
            }
        }).joinWithSeparator(", ")
    }
    
    init(USEmbassyQuery query: USEmbassyQuery, city: String, timestamp: NSDate, PM2_5: Double, AQI: Int, rating: String) {
        self.timestamp = timestamp
        self.city = city
        self.query = query
        self.PM25 = AirQualityParameter(pollutantType: Pollutant.PM2_5, currentValue: PM2_5, dayAverageValue: nil, unit: .MicrogramsPerCubicMeter)
        self.AQI = AQI
        self.airQuality = USEmbassyAirQualityRating.ratingFromAPIObject(APIObject: rating)
        super.init()
    }
    
    init?(pm25Query query: PM25Query, dictionary: [String: AnyObject]) {
        self.query = query
        
        guard let timeString = dictionary["time_point"] as? String, city = dictionary["area"] as? String else {
            timestamp = nil
            self.city = ""
            super.init()
            return nil
        }
        
        self.city = city
        timestamp = NSDate.pm25_dateFromString(timeString)!
        
        let parseDict: (type: Pollutant, dict: [String: AnyObject], field: String, unit: AirQualityParameter.Unit) -> AirQualityParameter = { type, dict, field, unit in
            let field_24h = field + "_24h"
            let value = dict[field] as? Double
            let dayValue = dict[field_24h] as? Double
            let param = AirQualityParameter(pollutantType: type, currentValue: value!, dayAverageValue: dayValue, unit: unit)
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
            primaryPollutant = Pollutant(APIObject: dictionary["primary_pollutant"])
            let qualityObject = dictionary["quality"]
            guard let airQuality = ChinaAirQualityRating.ratingFromAPIObject(APIObject: qualityObject) else {
                print("Error: query \(query.URL) fail to convert \(qualityObject) to air quality. It is probably a bad sample. Discarded.")
                super.init()
                return nil
            }
            self.airQuality = airQuality
        default:
            super.init()
            return nil
        }
        
        let unit: AirQualityParameter.Unit

        switch field {
        case "co":
            unit = AirQualityParameter.Unit.MiligramsPerCubicMeter
        default:
            unit = AirQualityParameter.Unit.MicrogramsPerCubicMeter
        }
        
        // Extract individual properties
        switch query {
        case .CityPM10(_):
            PM10 = parseDict(type: Pollutant.PM10, dict: dictionary, field: field, unit: unit)
        case .CityPM2_5(_):
            PM25 = parseDict(type: Pollutant.PM2_5, dict: dictionary, field: field, unit: unit)
        case .CitySO2(_):
            SO2 = parseDict(type: Pollutant.SO2, dict: dictionary, field: field, unit: unit)
        case .CityCO(_):
            CO = parseDict(type: Pollutant.CO, dict: dictionary, field: field, unit: unit)
        case .CityNO2(_):
            NO2 = parseDict(type: Pollutant.NO2, dict: dictionary, field: field, unit: unit)
        case .CityO3(_):
            O3 = parseDict(type: Pollutant.O3, dict: dictionary, field: field, unit: unit)
            O3_8h = parseDict(type: Pollutant.O3_8h, dict: dictionary, field: "\(field)_8h", unit: unit)
        case .CityAQI(_):
            AQI = (dictionary["aqi"] as! Int)
        case .CityDetails(_), .StationDetails(_), .AllCityDetails, .AllCityRanking:
            let coUnit = AirQualityParameter.Unit.MiligramsPerCubicMeter
            let otherUnit = AirQualityParameter.Unit.MicrogramsPerCubicMeter
            PM10 = parseDict(type: Pollutant.PM10, dict: dictionary, field: "pm10", unit: otherUnit)
            PM25 = parseDict(type: Pollutant.PM2_5, dict: dictionary, field: "pm2_5", unit: otherUnit)
            SO2 = parseDict(type: Pollutant.SO2, dict: dictionary, field: "so2", unit: otherUnit)
            NO2 = parseDict(type: Pollutant.NO2, dict: dictionary, field: "no2", unit: otherUnit)
            CO = parseDict(type: Pollutant.CO, dict: dictionary, field: "co", unit: coUnit)
            O3 = parseDict(type: Pollutant.O3, dict: dictionary, field: "o3", unit: otherUnit)
            O3_8h = parseDict(type: Pollutant.O3_8h, dict: dictionary, field: "o3_8h", unit: otherUnit)
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

