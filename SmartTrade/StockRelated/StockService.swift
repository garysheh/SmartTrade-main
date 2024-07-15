//
//  StockService.swift
//  SmartTrade
//
//  Created by Gary She on 2024/5/27.
//

import Foundation
import Combine

// method reference: https://developer.apple.com/documentation/foundation/urlsession
struct APIService {
    
    var API_KEY: String {
        return keys.randomElement() ?? ""
    }
    
    let keys = ["DISNIARK9SAG0OW3"]
    
    func fetchSymbolsPublisher(symbol: String) -> AnyPublisher<Data, Error> {
        let keys = ["DISNIARK9SAG0OW3"]
        let API_KEY = keys.randomElement() ?? ""
        let urlString = "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=\(symbol)&apikey=\(API_KEY)"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    // fetch stock details 
        func fetchStockDetails(symbol: String) -> AnyPublisher<SearchResult, Error> {
            let urlString = "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=\(symbol)&apikey=\(API_KEY)"
            guard let url = URL(string: urlString) else {
                return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
            }
            
            return URLSession.shared.dataTaskPublisher(for: url)
                .map { $0.data }
                .decode(type: SearchResults.self, decoder: JSONDecoder())
                .map { $0.globalQuote }
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
        }
    
    // fetch daily price data
    func fetchDailyPricesPublisher(symbol: String) -> AnyPublisher<[Double], Error> {
            let urlString = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=\(symbol)&apikey=\(API_KEY)"
            guard let url = URL(string: urlString) else {
                return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
            }
            
            return URLSession.shared.dataTaskPublisher(for: url)
                .map { $0.data }
                .decode(type: TimeDailySeries.self, decoder: JSONDecoder())
                .map { response in
                    let sortedDates = response.timeSeriesDaily.keys.sorted()
                    return sortedDates.compactMap { Double(response.timeSeriesDaily[$0]?.close ?? "") }
                }
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
        }
    
    // fetch weekly price data
    func fetchWeeklyPricesPublisher(symbol: String) -> AnyPublisher<[Double], Error> {
            let urlString = "https://www.alphavantage.co/query?function=TIME_SERIES_WEEKLY&symbol=\(symbol)&apikey=\(API_KEY)"
            guard let url = URL(string: urlString) else {
                return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
            }
            
            return URLSession.shared.dataTaskPublisher(for: url)
                .map { $0.data }
                .decode(type: TimeWeeklySeries.self, decoder: JSONDecoder())
                .map { response in
                    let sortedDates = response.timeSeriesWeekly.keys.sorted()
                    return sortedDates.compactMap { Double(response.timeSeriesWeekly[$0]?.close ?? "") }
                }
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
        }
    
    // fetch montly price data
    func fetchMonthlyPricesPublisher(symbol: String) -> AnyPublisher<[Double], Error> {
            let urlString = "https://www.alphavantage.co/query?function=TIME_SERIES_MONTHLY&symbol=\(symbol)&apikey=\(API_KEY)"
            guard let url = URL(string: urlString) else {
                return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
            }
            
            return URLSession.shared.dataTaskPublisher(for: url)
                .map { $0.data }
                .decode(type: TimeMonthlySeries.self, decoder: JSONDecoder())
                .map { response in
                    let sortedDates = response.timeSeriesMonthly.keys.sorted()
                    return sortedDates.compactMap { Double(response.timeSeriesMonthly[$0]?.close ?? "") }
                }
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
        }
    
    // fetch stock name
    func fetchStockFullName(symbol: String) -> AnyPublisher<BestMatch, Error> {
            let urlString = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(symbol)&apikey=\(API_KEY)"
            guard let url = URL(string: urlString) else {
                return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
            }

            return URLSession.shared.dataTaskPublisher(for: url)
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                        throw URLError(.badServerResponse)
                    }
                    return data
                }
                .decode(type: SymbolSearchResponse.self, decoder: JSONDecoder())
                .tryMap { response in
                    guard let bestMatch = response.bestMatches.first else {
                        throw URLError(.cannotFindHost)
                    }
                    return bestMatch
                }
                .eraseToAnyPublisher()
        }
    
    func fetchHourlyPricesPublisher(symbol: String) -> AnyPublisher<[Double], Error> {
            let urlString = "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=\(symbol)&interval=60min&apikey=\(API_KEY)"
            guard let url = URL(string: urlString) else {
                return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
            }
            
            return URLSession.shared.dataTaskPublisher(for: url)
                .map { $0.data }
                .decode(type: TimeHourlySeries.self, decoder: JSONDecoder())
                .map { response in
                    let sortedDates = response.timeSeriesHourly.keys.sorted()
                    return sortedDates.compactMap { Double(response.timeSeriesHourly[$0]?.close ?? "") }
                }
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
        }
    

    
    func fetchThirtyMinutePricesPublisher(symbol: String) -> AnyPublisher<[Double], Error> {
            let urlString = "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=\(symbol)&interval=30min&apikey=\(API_KEY)"
            guard let url = URL(string: urlString) else {
                return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
            }

            return URLSession.shared.dataTaskPublisher(for: url)
                .map { $0.data }
                .decode(type: TimeThirtyMinuteSeries.self, decoder: JSONDecoder())
                .map { response in
                    let sortedDates = response.timeSeriesThirtyMinute.keys.sorted()
                    return sortedDates.compactMap { Double(response.timeSeriesThirtyMinute[$0]?.close ?? "") }
                }
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
        }
}
