//
//  TimeWeeklySeries.swift
//  SmartTrade
//
//  Created by Gary She on 2024/6/20.
//

import Foundation

struct TimeWeeklySeries: Codable {
    let timeSeriesWeekly: [String: TimeSeriesWeekly]
    enum CodingKeys: String, CodingKey {
        case timeSeriesWeekly = "Weekly Time Series"
    }
}

struct TimeSeriesWeekly: Codable {
    let open, high, low, close, volume: String
    
    enum CodingKeys: String, CodingKey {
        case open = "1. open"
        case high = "2. high"
        case low = "3. low"
        case close = "4. close"
        case volume = "5. volume"
    }
}
