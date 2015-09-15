//
//  PM25Tests.swift
//  PM25Tests
//
//  Created by Ben Lu on 7/23/15.
//  Copyright © 2015 DJ.Ben. All rights reserved.
//

import XCTest
@testable import PM25

class PM25Tests: XCTestCase {
    
    static let token = "theToken"
    
    static var nanjingPM25: [[String: AnyObject]]!
    static var nanjingCityDetails: [[String: AnyObject]]!
    static var nanjingMonitoringStations: [String: AnyObject]!
    static var cityNames: [String: AnyObject]!
    
    override class func setUp() {
        super.setUp()
        PM25Manager.sharedManager.token = token
        let pm25Path = NSBundle(forClass: self).pathForResource("pm25_nanjing", ofType: "json")!
        nanjingPM25 = try! NSJSONSerialization.JSONObjectWithData(NSData(contentsOfFile: pm25Path)!, options: NSJSONReadingOptions()) as! [[String: AnyObject]]
        let cityDetailsPath = NSBundle(forClass: self).pathForResource("city_details_nanjing", ofType: "json")!
        nanjingCityDetails = try! NSJSONSerialization.JSONObjectWithData(NSData(contentsOfFile: cityDetailsPath)!, options: NSJSONReadingOptions()) as! [[String: AnyObject]]
        let stationsPath = NSBundle(forClass: self).pathForResource("monitoring_stations_nanjing", ofType: "json")!
        nanjingMonitoringStations = try! NSJSONSerialization.JSONObjectWithData(NSData(contentsOfFile: stationsPath)!, options: NSJSONReadingOptions()) as! [String: AnyObject]
        let cityNamePath = NSBundle(forClass: self).pathForResource("city_names", ofType: "json")!
        cityNames = try! NSJSONSerialization.JSONObjectWithData(NSData(contentsOfFile: cityNamePath)!, options: NSJSONReadingOptions()) as! [String: AnyObject]
    }
    
    func test_1_1_to_1_6_url_formation_is_correct() {
        let queries: [PM25Query] = [PM25Query.CityPM2_5(city: "Nanjing", fields: .Default),
                                PM25Query.CityPM10(city: "Nanjing", fields: .Default),
                                PM25Query.CityNO2(city: "Nanjing", fields: .Default),
                                PM25Query.CitySO2(city: "Nanjing", fields: .Default),
                                PM25Query.CityO3(city: "Nanjing", fields: .Default),
                                PM25Query.CityCO(city: "Nanjing", fields: .Default),
                                PM25Query.CityAQI(city: "Nanjing", fields: .Default)]
        queries.forEach { query -> Void in
            let url = query.URL
            XCTAssertTrue((url.absoluteString as NSString).containsString("\(query.path)"), "should contain \(url.absoluteString)")
            checkQueries(url.query!, equalToParameters: ["token": PM25Tests.token, "city": "Nanjing".lowercaseString])
        }
    }
    
    func test_city_query_fields_are_correct() {
        let q1 = PM25Query.CityPM2_5(city: "Nanjing", fields: .Default)
        checkQueries(q1.URL.query!, equalToParameters: ["token": PM25Tests.token, "city": "Nanjing".lowercaseString, "avg": "true", "stations": "true"])
        let q2 = PM25Query.CityO3(city: "Beijing", fields: .Stations)
        checkQueries(q2.URL.query!, equalToParameters: ["token": PM25Tests.token, "city": "Beijing".lowercaseString, "avg": "false", "stations": "true"])
        let q3 = PM25Query.CityAQI(city: "Shanghai", fields: .Average)
        checkQueries(q3.URL.query!, equalToParameters: ["token": PM25Tests.token, "city": "Shanghai".lowercaseString, "avg": "true", "stations": "false"])
        
    }
    
    func test_timestamp_is_parsed_correctly() {
        let dateComponents = NSDateComponents()
        dateComponents.year = 2015
        dateComponents.month = 7
        dateComponents.day = 27
        dateComponents.hour = 9
        dateComponents.minute = 59
        dateComponents.second = 3
        dateComponents.timeZone = NSTimeZone(name: "Asia/Shanghai")
        let date = NSDate.pm25_dateFromString("2015-07-27T09:59:03Z")!
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        XCTAssertNotNil(date)
        let referenceDate = calendar?.dateFromComponents(dateComponents)
        XCTAssertNotNil(referenceDate)
        XCTAssertEqual(date, referenceDate!)
    }
    
    func test_monitoring_station_response_is_parsed_correctly() {
        let query = PM25Query.StationList(city: "Nanjing")
        let result = try! Result(query: query, json: PM25Tests.nanjingMonitoringStations)
        XCTAssertNil(result.samples)
        XCTAssertNil(result.cities)
        XCTAssertNotNil(result.monitoringStations)
        XCTAssertEqual(result.monitoringStations!.count, 9)
        let firstStation = result.monitoringStations![0]
        XCTAssertEqual(firstStation.code, "1151A")
        XCTAssertEqual(firstStation.name, "迈皋桥")
    }
    
    func test_city_name_response_is_parsed_correctly() {
        let query = PM25Query.CityNames
        let result = try! Result(query: query, json: PM25Tests.cityNames)
        XCTAssertNil(result.samples)
        XCTAssertNotNil(result.cities)
        XCTAssertNil(result.monitoringStations)
        XCTAssertTrue(result.cities!.count > 0)
        ["上海", "北京", "西双版纳州", "吉林"].forEach { (cityName) -> Void in
            XCTAssertTrue(result.cities!.contains(cityName))
        }
    }
    
    func test_pm2_5_is_parsed_correctly() {
        let query = PM25Query.CityPM2_5(city: "Nanjing", fields: .Default)
        let result = try! Result(query: query, json: PM25Tests.nanjingPM25)
        XCTAssertNotNil(result.samples)
        XCTAssertNil(result.cities)
        XCTAssertNil(result.monitoringStations)
        XCTAssertEqual(result.samples!.count, 10)
        
        // Test if last is average of the samples, while the others are not
        let avgSample = result.samples!.last!
        XCTAssertTrue(avgSample.isAverageSample)
        result.samples![0..<result.samples!.count - 1].forEach { (sample) -> Void in
            XCTAssertFalse(sample.isAverageSample)
        }
        result.samples!.forEach { sample -> Void in
            checkSampleIsValid(sample)
            checkField(sample.PM25)
        }
    }
    
    func test_city_details_are_parsed_correctly() {
        let query = PM25Query.CityDetails(city: "Nanjing")
        let result = try! Result(query: query, json: PM25Tests.nanjingCityDetails)
        XCTAssertNotNil(result.samples)
        XCTAssertNil(result.cities)
        XCTAssertNil(result.monitoringStations)
        let avgSample = result.samples!.last!
        XCTAssertTrue(avgSample.isAverageSample)
        result.samples![0..<result.samples!.count - 1].forEach { (sample) -> Void in
            XCTAssertFalse(sample.isAverageSample)
        }
        result.samples!.forEach { sample -> Void in
            checkSampleIsValid(sample)
            checkField(sample.PM25)
            checkField(sample.PM10)
            checkField(sample.CO)
            checkField(sample.SO2)
            checkField(sample.NO2)
            checkField(sample.O3)
            checkField(sample.O3_8h)
            XCTAssertEqual(sample.CO?.unit, AirQualityParameter.Unit.MiligramsPerCubicMeter)
            XCTAssertEqual(sample.PM10?.unit, AirQualityParameter.Unit.MicrogramsPerCubicMeter)
        }
    }
    
    func test_error_is_parsed_correctly() {
        let query = PM25Query.CityNames
        let json = ["error": "Invalid authentication token."]
        do {
            let _ = try Result(query: query, json: json)
            XCTFail("Should throw")
        } catch {
            switch error {
            case PM25Query.PM25QueryError.AuthenticationFailed:
                break
            default:
                XCTFail("Should be authentication failure error")
            }
        }
    }
    
    func test_parse_request_is_correct() {
        let query = PM25Query.CityNO2(city: "Haha", fields: .Default)
        if let backQuery = PM25Query.parseURL(query.URL) {
            switch backQuery {
            case let .CityNO2(city, fields):
                XCTAssertEqual(city, "Haha")
                XCTAssertEqual(fields, PM25Query.CityQueryField.Default)
            default:
                XCTFail()
            }
        } else {
            XCTFail("Query cannot be parsed back")
        }
        
        let queries: [Query] = [
            PM25Query.CitySO2(city: "Mahsd", fields: .Stations),
            PM25Query.CityPM2_5(city: "Lalala", fields: .Average),
            PM25Query.StationList(city: "dusi"),
            PM25Query.AllCityRanking,
            PM25Query.AllCityDetails
        ]
        queries.forEach { (query) -> () in
            XCTAssertEqual(PM25Query.parseURL(query.request.URL!)!.URL, query.request.URL!)
        }
    }
    
//    // This test will result a crash, a bug present in Xcode 7 beta 5
//    func test_result_init_with_data() {
//        let query = Query.CityNames
//        let data = "{\"error\": \"Invalid authentication token.\"}".dataUsingEncoding(NSUTF8StringEncoding)!
//        do {
//            let _ = try Result(query: query, data: data)
//        } catch {
//            switch error {
//            case Query.QueryError.AuthenticationFailed:
//                break
//            default:
//                XCTFail("Wrong error thrown")
//            }
//        }
//    }
    
    func checkField(field: AirQualityParameter?) {
        XCTAssertNotNil(field)
        XCTAssertNotNil(field!.currentValue)
        XCTAssertNotNil(field!.dayAverageValue)
    }
    
    func checkSampleIsValid(sample: DataSample) {
        guard sample.primaryPollutant != nil else {
            XCTFail("Primary pollutant is nil")
            return
        }
        guard sample.airQuality != nil else {
            XCTFail("Air quality is nil")
            return
        }
        XCTAssertNotNil(sample.timestamp)
    }
    
    func checkQueries(query: String, equalToParameters dict: [String: String]) {
        dict.forEach { (name, value) -> Void in
            XCTAssertTrue((query as NSString).containsString("\(name)=\(value)"), "query \(name) should have value \(value).")
        }
    }
}
