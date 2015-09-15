//
//  USEmbassyTests.swift
//  PM25
//
//  Created by Sihao Lu on 9/15/15.
//  Copyright © 2015 DJ.Ben. All rights reserved.
//

import XCTest
@testable import PM25

class USEmbassyTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testFetchingFromUSEmbassy() {
        let expectation = expectationWithDescription("US Embassy query")
        USEmbassyQuery.CityAQI(city: "北京").executeWithCompletion { (result, error) -> Void in
            if let sample = result?.samples?[0] {
                XCTAssertNotNil(sample.timestamp)
                XCTAssertNotNil(sample.AQI)
                XCTAssertNotNil(sample.airQuality)
                XCTAssertNotNil(sample.PM25)
                XCTAssertEqual("北京", sample.city)
            } else {
                XCTFail()
            }
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

}
