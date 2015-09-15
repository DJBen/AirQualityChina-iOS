//
//  AirQuality.swift
//  PM25
//
//  Created by Ben Lu on 8/4/15.
//  Copyright © 2015 DJ.Ben. All rights reserved.
//

public struct Pollutant: OptionSetType, CustomStringConvertible {
    public let rawValue: Int
    
    public static let PM2_5 = Pollutant(rawValue: 1)
    public static let PM10 = Pollutant(rawValue: 1 << 1)
    public static let SO2 = Pollutant(rawValue: 1 << 2)
    public static let O3 = Pollutant(rawValue: 1 << 3)
    public static let NO2 = Pollutant(rawValue: 1 << 4)
    public static let CO = Pollutant(rawValue: 1 << 5)
    public static let O3_8h = Pollutant(rawValue: 1 << 6)
    
    public var description: String {
        let items = [Pollutant.PM2_5, Pollutant.PM10, Pollutant.SO2, Pollutant.O3, Pollutant.O3_8h, Pollutant.NO2, Pollutant.CO]
        let separator = pm25_localizedString(", ", comment: "Primary pollutants separator")
        var pollutants = items.flatMap { (item) -> [String] in
            let key: String?
            if self.intersect(item) != Pollutant() {
                switch item {
                case Pollutant.PM2_5:
                    key = "PM2_5"
                case Pollutant.PM10:
                    key = "PM10"
                case Pollutant.SO2:
                    key = "SO2"
                case Pollutant.NO2:
                    key = "NO2"
                case Pollutant.O3:
                    key = "O3"
                case Pollutant.O3_8h:
                    key = "O3_8h"
                case Pollutant.CO:
                    key = "CO"
                default:
                    key = nil
                }
            } else {
                key = nil
            }
            if key != nil {
                return [pm25_localizedString(key!, comment: "Primary pollutants")]
            } else {
                return []
            }
        }
        if pollutants.isEmpty {
            pollutants += [pm25_localizedString("None", comment: "Primary pollutants")]
        }
        return pollutants.joinWithSeparator(separator)
    }
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public init(APIObject object: AnyObject?) {
        guard let string = object as? String else {
            self.init(rawValue: 0)
            return
        }
        let rawValue = string.componentsSeparatedByString(",").map { (componentString) -> Pollutant in
            switch componentString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) {
            case "二氧化硫":
                return Pollutant.SO2
            case "二氧化氮":
                return Pollutant.NO2
            case "一氧化碳":
                return Pollutant.CO
            case "臭氧1小时":
                return Pollutant.O3
            case "臭氧8小时":
                return Pollutant.O3_8h
            case "颗粒物(PM10)":
                return Pollutant.PM10
            case "细颗粒物(PM2.5)", "颗粒物(PM2.5)":
                return Pollutant.PM2_5
            case "", "-", "—":
                return Pollutant()
            default:
                print("Error: unrecognized primary pollutant \(componentString)")
                return Pollutant()
            }
            }.reduce(Pollutant()) { $0.union($1) }.rawValue
        self.init(rawValue: rawValue)
    }
}

public protocol AirQualityRating: CustomStringConvertible {
    var abbreviatedDescription: String { get }
    static func ratingFromAPIObject(APIObject object: AnyObject?) -> Self?
}

public enum ChinaAirQualityRating: AirQualityRating {
    case Great
    case Okay
    case LightlyPolluted
    case ModeratelyPolluted
    case HeavilyPolluted
    case SeverelyPolluted
    
    public var description: String {
        let key: String
        switch self {
        case .Great:
            key = "Great"
        case .Okay:
            key = "Okay"
        case .LightlyPolluted:
            key = "Lightly Polluted"
        case .ModeratelyPolluted:
            key = "Moderately Polluted"
        case .HeavilyPolluted:
            key = "Heavily Polluted"
        case .SeverelyPolluted:
            key = "Severely Polluted"
        }
        return pm25_localizedString(key, comment: "The description of air quality rating")
    }
    
    public var abbreviatedDescription: String {
        let key: String
        switch self {
        case .Great:
            key = "G"
        case .Okay:
            key = "OK"
        case .LightlyPolluted:
            key = "LP"
        case .ModeratelyPolluted:
            key = "MP"
        case .HeavilyPolluted:
            key = "HP"
        case .SeverelyPolluted:
            key = "SP"
        }
        return pm25_localizedString(key, comment: "The description of air quality rating, abbreviated")
    }
    
    public static func ratingFromAPIObject(APIObject object: AnyObject?) -> ChinaAirQualityRating? {
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

public class AirQualityParameter: NSObject {
    
    public enum Unit: String {
        case MicrogramsPerCubicMeter = "\u{3bc}g/m\u{b3}"
        case MiligramsPerCubicMeter = "mg/m\u{b3}"
    }
    
    public let pollutantType: Pollutant
    public let currentValue: Double
    public let dayAverageValue: Double?
    public let unit: Unit
    
    init(pollutantType: Pollutant, currentValue: Double, dayAverageValue: Double?, unit: Unit) {
        self.pollutantType = pollutantType
        self.currentValue = currentValue
        self.dayAverageValue = dayAverageValue
        self.unit = unit
        super.init()
    }
    
    public override var description: String {
        return (["\(currentValue)"] + (dayAverageValue != nil ? ["\(dayAverageValue!)"] : [])).joinWithSeparator(" | ")
    }

}
