//
//  Stock.swift
//  SmartTrade
//
//  Created by Gary She on 2024/5/27.
//

import Foundation

struct Stock: Codable {
    let symbol: String
    let price: Double
    let change: Double
    let changePercent: Double
}

struct AlphaVantageResponse: Codable {
    let globalQuote: GlobalQuote?
    
    enum CodingKeys: String, CodingKey {
        case globalQuote = "Global Quote"
    }
}

struct GlobalQuote: Codable {
    let symbol: String
        let price: String
        let change: String
        let changePercent: String

        enum CodingKeys: String, CodingKey {
            case symbol = "01. symbol"
            case price = "05. price"
            case change = "09. change"
            case changePercent = "10. change percent"
    }
}

