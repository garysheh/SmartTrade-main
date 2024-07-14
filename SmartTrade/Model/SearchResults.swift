//
//  SearchResults.swift
//  SmartTrade
//
//  Created by Gary She on 2024/5/27.
//

import Foundation

struct SearchResults: Decodable {
    let globalQuote: SearchResult

    enum CodingKeys: String, CodingKey {
        case globalQuote = "Global Quote"
    }
}

struct SearchResult: Decodable {
    let symbol: String
    let high: String
    let low: String
    let price: String
    let day: String
    let percent: String
    let change: String
    var dailyPrices: [Double]?


    enum CodingKeys: String, CodingKey {
        case symbol = "01. symbol"
        case high = "03. high"
        case low = "04. low"
        case price = "05. price"
        case day = "07. latest trading day"
        case change = "09. change"
        case percent = "10. change percent"
    }
}
