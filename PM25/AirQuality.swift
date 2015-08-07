//
//  AirQuality.swift
//  PM25
//
//  Created by Ben Lu on 8/4/15.
//  Copyright © 2015 DJ.Ben. All rights reserved.
//

public struct PrimaryPollutant: OptionSetType {
    public let rawValue: Int
    
    public static let PM2_5 = PrimaryPollutant(rawValue: 1)
    public static let PM10 = PrimaryPollutant(rawValue: 1 << 1)
    public static let SO2 = PrimaryPollutant(rawValue: 1 << 2)
    public static let O3 = PrimaryPollutant(rawValue: 1 << 3)
    public static let NO2 = PrimaryPollutant(rawValue: 1 << 4)
    public static let CO = PrimaryPollutant(rawValue: 1 << 5)
    public static let O3_8h = PrimaryPollutant(rawValue: 1 << 6)
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public init(APIObject object: AnyObject?) {
        guard let string = object as? String else {
            self.init(rawValue: 0)
            return
        }
        let rawValue = string.componentsSeparatedByString(",").map { (componentString) -> PrimaryPollutant in
            switch componentString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) {
            case "二氧化硫":
                return PrimaryPollutant.SO2
            case "二氧化氮":
                return PrimaryPollutant.NO2
            case "一氧化碳":
                return PrimaryPollutant.CO
            case "臭氧1小时":
                return PrimaryPollutant.O3
            case "臭氧8小时":
                return PrimaryPollutant.O3_8h
            case "颗粒物(PM10)":
                return PrimaryPollutant.PM10
            case "细颗粒物(PM2.5)", "颗粒物(PM2.5)":
                return PrimaryPollutant.PM2_5
            case "", "-", "—":
                return PrimaryPollutant()
            default:
                print("Error: unrecognized primary pollutant \(componentString)")
                return PrimaryPollutant()
            }
            }.reduce(PrimaryPollutant()) { $0.union($1) }.rawValue
        self.init(rawValue: rawValue)
    }
}

public enum AirQualityRating: CustomStringConvertible {
    case Great
    case Okay
    case LightlyPolluted
    case ModeratelyPolluted
    case HeavilyPolluted
    case SeverelyPolluted
    
    public var description: String {
        switch self {
        case .Great:
            return "Great"
        case .Okay:
            return "Okay"
        case .LightlyPolluted:
            return "Lightly polluted"
        case .ModeratelyPolluted:
            return "Moderately polluted"
        case .HeavilyPolluted:
            return "Heavily Polluted"
        case .SeverelyPolluted:
            return "Severely polluted"
        }
    }
    
    public static func ratingFromAPIObject(APIObject object: AnyObject?) -> AirQualityRating? {
        guard let string = object as? String else {
            return nil
        }
        switch string {
        case "优":
            return .Great
        case "良":
            return .Okay
        case "轻度污染":
            return .LightlyPolluted
        case "中度污染":
            return .ModeratelyPolluted
        case "重度污染":
            return .HeavilyPolluted
        case "严重污染":
            return .SeverelyPolluted
        default:
            return nil
        }
    }
}

public class AirQualityParameter: NSObject, NSCopying {
    public let currentValue: Double
    public let dayAverageValue: Double?
    
    init(currentValue: Double, dayAverageValue: Double?) {
        self.currentValue = currentValue
        self.dayAverageValue = dayAverageValue
        super.init()
    }
    
    public override var description: String {
        let dayAverageString = dayAverageValue != nil ? "\(dayAverageValue!)" : ""
        return "\(currentValue) | \(dayAverageString)"
    }
    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        let param = AirQualityParameter(currentValue: self.currentValue, dayAverageValue: self.dayAverageValue)
        return param
    }
}
