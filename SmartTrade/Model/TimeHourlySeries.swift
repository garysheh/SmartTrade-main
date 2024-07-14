//
//  TimeHourlySeries.swift
//  SmartTrade
//
//  Created by Gary She on 2024/6/26.
//

import Foundation

struct TimeHourlySeries: Codable {
    let timeSeriesHourly: [String: TimeSeriesHourly]
    
    enum CodingKeys: String, CodingKey {
        case timeSeriesHourly = "Time Series (60min)"
    }
}

struct TimeSeriesHourly: Codable {
    let open, high, low, close, volume: String
    
    enum CodingKeys: String, CodingKey {
        case open = "1. open"
        case high = "2. high"
        case low = "3. low"
        case close = "4. close"
        case volume = "5. volume"
    }
}
