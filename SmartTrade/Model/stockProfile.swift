//
//  stockProfile.swift
//  SmartTrade
//
//  Created by Gary She on 2024/6/20.
//

import Foundation

struct SymbolSearchResponse: Decodable {
    let bestMatches: [BestMatch]
}

struct BestMatch: Decodable {
    let symbol: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case symbol = "1. symbol"
        case name = "2. name"
    }
}
