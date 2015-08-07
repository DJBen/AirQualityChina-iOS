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

