//
//  TimeMonthlySeries.swift
//  SmartTrade
//
//  Created by Gary She on 2024/6/20.
//

import Foundation

struct TimeMonthlySeries: Codable {
    let timeSeriesMonthly: [String: TimeSeriesMonthly]
    enum CodingKeys: String, CodingKey {
        case timeSeriesMonthly = "Monthly Time Series"
    }
}

struct TimeSeriesMonthly: Codable {
    let open, high, low, close, volume: String
    
    enum CodingKeys: String, CodingKey {
        case open = "1. open"
        case high = "2. high"
        case low = "3. low"
        case close = "4. close"
        case volume = "5. volume"
    }
}
