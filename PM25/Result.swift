//
//  Result.swift
//  PM25
//
//  Created by Ben Lu on 8/4/15.
//  Copyright © 2015 DJ.Ben. All rights reserved.
//

public class Result: NSObject {
    
    public internal(set) var samples: [DataSample]?
    public internal(set) var monitoringStations: [Station]?
    public internal(set) var cities: [String]?
    
    public let query: Query
    
    // Warning: this method will throw EXC_BAD_ACCESS error, and I don't know why
    convenience init(query: Query, data: NSData) throws {
        if let dict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? NSObject {
            try self.init(query: query, json: dict)
        } else {
            try self.init(query: query, data: NSData())
            throw Query.QueryError.ParseError
        }
    }
    
    init(query: Query, json: AnyObject) throws {
        self.query = query
        
        if let dict = json as? [String: AnyObject], errorMessage = dict["error"] as? String {
            super.init()
            switch errorMessage {
            case "参数不能为空":
                throw Query.QueryError.MissingParameter
            case "该城市还未有PM2.5数据":
                throw Query.QueryError.NoData
            case "Sorry，您这个小时内的API请求次数用完了，休息一下吧！":
                throw Query.QueryError.APICallLimitReached
            case "You need to sign in or sign up before continuing.", "Invalid authentication token.":
                throw Query.QueryError.AuthenticationFailed
            default:
                print("Error: unexpected error message: \(errorMessage)")
                throw Query.QueryError.UnknownError
            }
        }
        
        switch query {
        case .CityPM10(_), .CityNO2(_), .CityO3(_), .CitySO2(_), .CityCO(_), .CityPM2_5(_), .CityAQI(_), .CityDetails(_), .StationDetails(_), .AllCityRanking, .AllCityDetails:
            guard let collection = json as? [[String: AnyObject]] else {
                super.init()
                throw Query.QueryError.ParseError
            }
            self.samples = collection.flatMap { rawSample -> [DataSample] in
                if let sample = DataSample(query: query, dictionary: rawSample) {
                    return [sample]
                } else {
                    return []
                }
            }
        case .StationList(_):
            guard let stationDict = json as? [String: AnyObject], stationList = stationDict["stations"] as? [[String: String]] where stationDict["city"] is String else {
                super.init()
                throw Query.QueryError.ParseError
            }
            self.monitoringStations = stationList.flatMap { (rawStation) -> [Station] in
                if let station = Station(dictionary: rawStation) {
                    return [station]
                } else {
                    return []
                }
            }
        case .CityNames:
            guard let stationDict = json as? [String: AnyObject], cities = stationDict["cities"] as? [String] else {
                super.init()
                throw Query.QueryError.ParseError
            }
            self.cities = cities
        }
        super.init()
    }
    
}
