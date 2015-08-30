//
//  Query.swift
//  PM25
//
//  Created by Ben Lu on 7/27/15.
//  Copyright © 2015 DJ.Ben. All rights reserved.
//

public typealias QueryExecutionBlock = (result: Result?, error: NSError?) -> Void

public enum Query: Hashable {
    
    public enum QueryError: ErrorType {
        case ParseError
        case MissingParameter
        case NoData
        case APICallLimitReached
        case AuthenticationFailed
        case UnknownError
    }
    
    public struct CityQueryField: OptionSetType {
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let Stations = CityQueryField(rawValue: 1)
        public static let Average = CityQueryField(rawValue: 1 << 1)
        public static let Default = CityQueryField(rawValue: 1 | 1 << 1)
        
        init(queryItems: [NSURLQueryItem]) {
            self.init(rawValue: queryItems.map { (queryItem) -> CityQueryField in
                switch queryItem.name {
                case "stations":
                    return queryItem.value == "true" ? CityQueryField.Stations : CityQueryField()
                case "avg":
                    return queryItem.value == "true" ? CityQueryField.Average : CityQueryField()
                default:
                    return CityQueryField()
                }
            }.reduce(CityQueryField()) { $0.union($1) }.rawValue)
        }
        
        var queryItems: [NSURLQueryItem] {
            var queryItems = [NSURLQueryItem]()
            queryItems.append(NSURLQueryItem(name: "stations", value: contains(CityQueryField.Stations) ? "true": "false"))
            queryItems.append(NSURLQueryItem(name: "avg", value: contains(CityQueryField.Average) ? "true": "false"))
            return queryItems
        }
    }
    
    case CityPM2_5(city: String, fields: CityQueryField)
    case CityPM10(city: String, fields: CityQueryField)
    case CityCO(city: String, fields: CityQueryField)
    case CityNO2(city: String, fields: CityQueryField)
    case CitySO2(city: String, fields: CityQueryField)
    case CityO3(city: String, fields: CityQueryField)
    case CityAQI(city: String, fields: CityQueryField)
    case CityDetails(city: String)
    case StationDetails(stationCode: String)
    case StationList(city: String?)
    case CityNames
    case AllCityDetails
    case AllCityRanking
    
    var path: String {
        switch self {
        case .CityPM2_5(_):
            return "/querys/pm2_5.json"
        case .CityPM10(_):
            return "/querys/pm10.json"
        case .CityCO(_):
            return "/querys/co.json"
        case .CityNO2(_):
            return "/querys/no2.json"
        case .CitySO2(_):
            return "/querys/so2.json"
        case .CityO3(_):
            return "/querys/o3.json"
        case .CityAQI(_):
            return "/querys/only_aqi.json"
        case .CityDetails(_):
            return "/querys/aqi_details.json"
        case .StationDetails(_):
            return "/querys/aqis_by_station.json"
        case .StationList(_):
            return "/querys/station_names.json"
        case .CityNames:
            return "/querys.json"
        case .AllCityDetails:
            return "/querys/all_cities.json"
        case .AllCityRanking:
            return "/querys/aqi_ranking.json"
        }
    }
    
    var queryItems: [NSURLQueryItem] {
        let returnItems: (String?, CityQueryField?) -> [NSURLQueryItem] = { city, fields in
            let cityQueryItem = city != nil ? [NSURLQueryItem(name: "city", value: city!.lowercaseString)] : []
            return cityQueryItem + (fields?.queryItems ?? [])
        }
        switch self {
        case let .CityPM2_5(city, fields):
            return returnItems(city, fields)
        case let .CityPM10(city, fields):
            return returnItems(city, fields)
        case let .CityCO(city, fields):
            return returnItems(city, fields)
        case let .CityNO2(city, fields):
            return returnItems(city, fields)
        case let .CityO3(city, fields):
            return returnItems(city, fields)
        case let .CitySO2(city, fields):
            return returnItems(city, fields)
        case let .CityAQI(city, fields):
            return returnItems(city, fields)
        case let .CityDetails(city):
            return returnItems(city, nil)
        case let .StationList(city):
            return returnItems(city, nil)
        case let .StationDetails(stationCode):
            return [NSURLQueryItem(name: "station_code", value: stationCode)]
        default:
            return []
        }
    }
    
    var URL: NSURL {
        let components = NSURLComponents()
        components.scheme = "http"
        components.host = PM25Manager.apiHost
        components.path = (PM25Manager.apiPath as NSString).stringByAppendingPathComponent(path)
        components.queryItems = [NSURLQueryItem(name: "token", value: PM25Manager.sharedManager.token ?? "Unknown token")] + queryItems
        let url = components.URL!
        return url
    }
    
    public var request: NSURLRequest {
        return NSURLRequest(URL: URL)
    }
    
    public var hashValue: Int {
        return "PM25.Query".hash + URL.hash
    }
    
    public static func parseURL(URL: NSURL) -> Query? {
        guard let components = NSURLComponents(URL: URL, resolvingAgainstBaseURL: false), path = components.path where components.scheme == "http" && components.host == PM25Manager.apiHost else {
            return nil
        }
        
        let city = components.queryItems?.filter({ $0.name == "city" }).first?.value?.capitalizedString
        let field = CityQueryField(queryItems: components.queryItems ?? [])
        let stationCode = components.queryItems?.filter({ $0.name == "station_code" }).first?.value
        
        switch (path as NSString).lastPathComponent {
        case "pm2_5.json":
            guard city != nil else { return nil }
            return Query.CityPM2_5(city: city!, fields: field)
        case "pm10.json":
            guard city != nil else { return nil }
            return Query.CityPM10(city: city!, fields: field)
        case "co.json":
            guard city != nil else { return nil }
            return Query.CityCO(city: city!, fields: field)
        case "no2.json":
            guard city != nil else { return nil }
            return Query.CityNO2(city: city!, fields: field)
        case "so2.json":
            guard city != nil else { return nil }
            return Query.CitySO2(city: city!, fields: field)
        case "o3.json":
            guard city != nil else { return nil }
            return Query.CityO3(city: city!, fields: field)
        case "only_aqi.json":
            guard city != nil else { return nil }
            return Query.CityAQI(city: city!, fields: field)
        case "aqi_details.json":
            guard city != nil else { return nil }
            return Query.CityDetails(city: city!)
        case "aqis_by_station.json":
            guard city != nil else { return nil }
            return Query.StationDetails(stationCode: stationCode!)
        case "station_names.json":
            guard city != nil else { return nil }
            return Query.StationList(city: city!)
        case "querys.json":
            return Query.CityNames
        case "all_cities.json":
            return Query.AllCityDetails
        case "aqi_ranking.json":
            return Query.AllCityRanking
        default:
            return nil
        }
    }
    
    public func executeWithCompletion(completionBlock: QueryExecutionBlock) {
        let task = NSURLSession.sharedSession().dataTaskWithURL(URL, completionHandler: parseResponseWithHandler(completionBlock))
        task.resume()
    }
    
    public func parseResponseWithHandler(handler: QueryExecutionBlock) -> ((NSData?, NSURLResponse?, NSError?) -> Void) {
        let handler: (NSData?, NSURLResponse?, NSError?) -> Void = { (data, response, error) -> Void in
            let mainThreadHandler: QueryExecutionBlock = { (result, error) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    handler(result: result, error: error)
                }
            }
            guard error == nil else {
                mainThreadHandler(result: nil, error: error)
                return
            }
            let result: Result?
            do {
                result = try self.parseData(data!)
                mainThreadHandler(result: result, error: nil)
            } catch let requestError {
                result = nil
                mainThreadHandler(result: nil, error: requestError as NSError)
            }
        }
        return handler
    }
    
    public func parseData(data: NSData) throws -> Result {
        do {
            if let object = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? NSObject {
                return try Result(query: self, json: object)
            } else {
                throw Query.QueryError.ParseError
            }
        } catch is NSCocoaError {
            throw Query.QueryError.ParseError
        } catch {
            throw error
        }
    }

}

public func ==(lhs: Query, rhs: Query) -> Bool {
    return lhs.URL == rhs.URL
}

