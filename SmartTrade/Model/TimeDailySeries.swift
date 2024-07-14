//
//  TimeDailySeries.swift
//  SmartTrade
//
//  Created by Gary She on 2024/6/15.
//

import Foundation

struct TimeDailySeries: Codable {
    let timeSeriesDaily: [String: TimeSeriesDaily]
    enum CodingKeys: String, CodingKey {
        case timeSeriesDaily = "Time Series (Daily)"
    }
}

struct TimeSeriesDaily: Codable {
    let open, high, low, close, volume: String
        
    enum CodingKeys: String, CodingKey {
        case open = "1. open"
        case high = "2. high"
        case low = "3. low"
        case close = "4. close"
        case volume = "5. volume"
    }
}

