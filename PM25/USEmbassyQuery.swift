//
//  USEmbassyQuery.swift
//  PM25
//
//  Created by Sihao Lu on 9/15/15.
//  Copyright © 2015 DJ.Ben. All rights reserved.
//

import PM25TFHpple

public enum USEmbassyQuery: Query {
    
    public enum USEmbassyQueryError: QueryError {
        case ParseWebpageError
        case ParseDataError
    }
    
    private static let apiHost = "www.stateair.net"
    
    case CityAQI(city: String)
    case CityNames
    
    private static let cityWebpageMappings: [String: Int] = ["北京": 1, "成都": 2, "广州": 3, "上海": 4, "沈阳": 5]
    private static let cities = ["北京", "成都", "广州", "上海", "沈阳"]
    private static let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM D, yyyy h a"
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        formatter.timeZone = NSTimeZone(name: "Asia/Shanghai")
        return formatter
    }()

    var URL: NSURL {
        switch self {
        case .CityNames:
            return NSURL()
        case .CityAQI(let city):
            let components = NSURLComponents()
            components.scheme = "http"
            components.host = USEmbassyQuery.apiHost
            let pageIndex = USEmbassyQuery.cityWebpageMappings[city]
            components.path = ("/web/post/1" as NSString).stringByAppendingPathComponent("\(pageIndex!).html")
            let url = components.URL!
            return url
        }
    }
    
    public var request: NSURLRequest {
        return NSURLRequest(URL: URL)
    }
    
    public func executeWithCompletion(completionBlock: QueryExecutionBlock) {
        switch self {
        case .CityNames:
            completionBlock(result: Result(USEmbassyQuery: self, cities: USEmbassyQuery.cities), error: nil)
            return
        case .CityAQI(_):
            let task = NSURLSession.sharedSession().dataTaskWithURL(URL, completionHandler: parseResponseWithHandler(completionBlock))
            task.resume()
        }
    }
    
    public func parseResponseWithHandler(handler: QueryExecutionBlock) -> ((NSData?, NSURLResponse?, NSError?) -> Void) {
        let handler: (NSData?, NSURLResponse?, NSError?) -> Void = { (data, response, error) -> Void in
            switch self {
            case .CityNames:
                handler(result: Result(USEmbassyQuery: self, cities: USEmbassyQuery.cities), error: nil)
                return
            case .CityAQI(_):
                let mainThreadCompletionBlock: QueryExecutionBlock = { result, error in
                    dispatch_async(dispatch_get_main_queue()) {
                        handler(result: result, error: error)
                    }
                }
                guard error == nil else {
                    mainThreadCompletionBlock(result: nil, error: error)
                    return
                }
                do {
                    let result = try self.parseData(data!)
                    mainThreadCompletionBlock(result: result, error: nil)
                } catch {
                    mainThreadCompletionBlock(result: nil, error: error as NSError)
                }
            }
        }
        return handler
    }
    
    public static func parseURL(URL: NSURL) -> USEmbassyQuery? {
        guard let components = NSURLComponents(URL: URL, resolvingAgainstBaseURL: false), pathString = components.path where components.scheme == "http" && components.host == USEmbassyQuery.apiHost else {
            return nil
        }
        let path = pathString as NSString
        guard let index = Int((path.lastPathComponent as NSString).stringByDeletingPathExtension) where path.pathExtension == "html" else {
            return nil
        }
        let city = cityWebpageMappings.filter { $0.1 == index }.first?.0
        guard city != nil else {
            return nil
        }
        return USEmbassyQuery.CityAQI(city: city!)
    }
    
    public func parseData(data: NSData) throws -> Result {
        guard case .CityAQI(let city) = self else {
            throw USEmbassyQuery.USEmbassyQueryError.ParseDataError
        }
        let document = PM25TFHpple(HTMLData: data)
        let basePath = "//div[contains(@class, 'currentExposure')]"
        let timestampPath = "//tr[1]/th/span"
        // AQI format: ### AQI
        let aqiPath = "//tr[2]/td"
        let ratingPath = "//tr[3]/td"
        // Concentration format: Concentration: ## \mu g/m^3
        let concentrationPath = "//tr[5]/th/span"
        if let timestamp = document.peekAtSearchWithXPathQuery(basePath + timestampPath).text()?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()),
            time = USEmbassyQuery.dateFormatter.dateFromString(timestamp),
            aqiString = document.peekAtSearchWithXPathQuery(basePath + aqiPath).text()?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).componentsSeparatedByString(" ")[0],
            aqi = Int(aqiString),
            rating = document.peekAtSearchWithXPathQuery(basePath + ratingPath).text()?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()),
            concentrationString = document.peekAtSearchWithXPathQuery(basePath + concentrationPath).text()?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "\r\n\t")).joinWithSeparator("") {
                let components = concentrationString.componentsSeparatedByString(" ")
                if components.count > 2 {
                    let concentration = components[1]
                    let sample = DataSample(USEmbassyQuery: self, city: city, timestamp: time, PM2_5: Double(concentration)!, AQI: aqi, rating: rating)
                    let result = Result(USEmbassyQuery: self, sample: sample)
                    return result
                } else {
                    throw USEmbassyQuery.USEmbassyQueryError.ParseDataError
                }
        } else {
            throw USEmbassyQuery.USEmbassyQueryError.ParseDataError
        }
    }
}

public enum USEmbassyAirQualityRating: AirQualityRating {
    case Good
    case Moderate
    case UnhealthyForSensitiveGroups
    case Unhealty
    case VeryUnhealthy
    case Hazardous
    case BeyondIndex
    
    public var description: String {
        let key: String
        switch self {
        case .Good:
            key = "Good"
        case .Moderate:
            key = "Moderate"
        case .UnhealthyForSensitiveGroups:
            key = "Unhealthy for Sensitive Groups"
        case .Unhealty:
            key = "Unhealthy"
        case .VeryUnhealthy:
            key = "Very Unhealthy"
        case .Hazardous:
            key = "Hazardous"
        case .BeyondIndex:
            key = "BeyondIndex"
        }
        return pm25_localizedString(key, comment: "The description of air quality rating")
    }
    
    public var abbreviatedDescription: String {
        let key: String
        switch self {
        case .Good:
            key = "G"
        case .Moderate:
            key = "M"
        case .UnhealthyForSensitiveGroups:
            key = "USG"
        case .Unhealty:
            key = "U"
        case .VeryUnhealthy:
            key = "VU"
        case .Hazardous:
            key = "H"
        case .BeyondIndex:
            key = "!!!"
        }
        return pm25_localizedString(key, comment: "The description of air quality rating, abbreviated")
    }
    
    public static func ratingFromAPIObject(APIObject object: AnyObject?) -> USEmbassyAirQualityRating? {
        guard let string = object as? String else {
            return nil
        }
        switch string {
        case "Good":
            return .Good
        case "Moderate":
            return .Moderate
        case "Unhealthy for Sensitive Groups":
            return .UnhealthyForSensitiveGroups
        case "Unhealthy":
            return .Unhealty
        case "Very Unhealthy":
            return .VeryUnhealthy
        case "Hazardous":
            return .Hazardous
        case "Beyond Index":
            return .BeyondIndex
        default:
            return nil
        }
    }
}
