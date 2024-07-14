//
//  TimeThirtyMinuteSeries.swift
//  SmartTrade
//
//  Created by Gary She on 2024/6/27.
//

import Foundation

import Foundation

struct TimeThirtyMinuteSeries: Codable {
    let timeSeriesThirtyMinute: [String: TimeSeriesThirtyMinute]
    
    enum CodingKeys: String, CodingKey {
        case timeSeriesThirtyMinute = "Time Series (30min)"
    }
}

struct TimeSeriesThirtyMinute: Codable {
    let open, high, low, close, volume: String
    
    enum CodingKeys: String, CodingKey {
        case open = "1. open"
        case high = "2. high"
        case low = "3. low"
        case close = "4. close"
        case volume = "5. volume"
    }
}
