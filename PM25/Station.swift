//
//  Station.swift
//  PM25
//
//  Created by Ben Lu on 7/24/15.
//  Copyright © 2015 DJ.Ben. All rights reserved.
//

public class Station: NSObject {
    
    public let name: String
    public let code: String
    
    public override var description: String {
        return "\(name) (\(code))"
    }
    
    public convenience init?(dictionary: [String: AnyObject]) {
        // Accept either "station_name" or "position_name"
        guard let name = (dictionary["station_name"] as? String ?? dictionary["position_name"] as? String), code = dictionary["station_code"] as? String else {
            self.init(name: "", code: "")
            return nil
        }
        self.init(name: name, code: code)
    }
    
    init(name: String, code: String) {
        self.name = name
        self.code = code
        super.init()
    }
}
