//
//  PM25Manager.swift
//  PM25
//
//  Created by Ben Lu on 7/23/15.
//  Copyright © 2015 DJ.Ben. All rights reserved.
//

public typealias MonitoringStationBlock = (stations: [Station]?, error: NSError?) -> Void
public typealias CityNamesBlock = (cities: [String]?, error: NSError?) -> Void

public class PM25Manager: NSObject {

    static let apiHost = "www.pm25.in"
    static let apiPath = "/api"
    
    public var token: String?

    public static let sharedManager = PM25Manager()
    
    private override init() {
        super.init()
    }
    
    public func monitoringStationsInCity(city: String, completionBlock: MonitoringStationBlock) {
        Query.StationList(city: city).executeWithCompletion { (result, error) -> Void in
            completionBlock(stations: result?.monitoringStations, error: error)
        }
    }
    
    public func fetchCityNamesWithCompletion(completionBlock: CityNamesBlock) {
        Query.CityNames.executeWithCompletion { (result, error) -> Void in
            completionBlock(cities: result?.cities, error: error)
        }
    }
}

public func pm25_localizedString(key: String, comment: String?) -> String {
    let bundle = NSBundle(forClass: PM25Manager.self)
    return pm25_localizedStringForKey(key, value: nil, table: nil, bundle: bundle)
}

func pm25_localizedStringForKey(key: String, value: String?, table: String?, bundle: NSBundle?) -> String {
    let kLocalizedStringNotFound = "kLocalizedStringNotFound"
    // First try main bundle
    var string: String = NSBundle.mainBundle().localizedStringForKey(key, value: kLocalizedStringNotFound, table: table)
    
    // Then try the backup bundle
    if string == kLocalizedStringNotFound {
        string = bundle!.localizedStringForKey(key, value: kLocalizedStringNotFound, table: table)
    }
    
    // Still not found?
    if string == kLocalizedStringNotFound {
        print("No localized string for '\(key)' in '\(table)'")
        if let value = value {
            string = value.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 ? value : key
        } else {
            string = key
        }
    }
    
    return string
}