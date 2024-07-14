//
//  StrategyViewController.swift
//  SmartTrade
//
//  Created by Gary She on 2024/6/26.
//

import UIKit
import Combine
//import NewsAPISwift

class StrategyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var segmentOutlet: UISegmentedControl!

    @IBOutlet weak var newsSegmentView: UIView!
    
    @IBOutlet weak var spreadView: UIView!

    private let apiService = APIService()
    private var subscribers = Set<AnyCancellable>()
    private var searchResults: [SearchResult] = []
    @Published private var searchQuery = String()
    var emailID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.bringSubviewToFront(tableView)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.layer.cornerRadius = 15
        tableView.layer.masksToBounds = true
        self.tabBarController?.selectedIndex = 0
        performSearch()
    }
    
    
    @IBAction func segmentAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.view.bringSubviewToFront(tableView)
        case 1:
            self.view.bringSubviewToFront(newsSegmentView)
        case 2:
            self.view.bringSubviewToFront(spreadView)
            
        default:
            break
        }
        
    }
    
    private func performSearch() {
            let symbols = ["TSLA", "LI"]
            let publishers = symbols.map { symbol -> AnyPublisher<(SearchResult?, [Double]), Error> in
                let symbolPublisher = apiService.fetchSymbolsPublisher(symbol: symbol)
                    .map { data -> SearchResult? in
                        if let searchResults = try? JSONDecoder().decode(SearchResults.self, from: data) {
                            return searchResults.globalQuote
                        }
                        return nil
                    }
                    .eraseToAnyPublisher()
                
                let pricesPublisher = apiService.fetchDailyPricesPublisher(symbol: symbol)
                    .eraseToAnyPublisher()
                
                return Publishers.Zip(symbolPublisher, pricesPublisher)
                    .eraseToAnyPublisher()
            }
            
            Publishers.MergeMany(publishers)
                .receive(on: RunLoop.main)
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        print(error.localizedDescription)
                    case .finished:
                        break
                    }
                } receiveValue: { (searchResult, dailyPrices) in
                    if var searchResult = searchResult {
                        searchResult.dailyPrices = dailyPrices
                        self.searchResults.append(searchResult)
                    }
                    self.tableView.reloadData()
                }
                .store(in: &subscribers)
        }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) ->
        Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500;//Choose your custom row height
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "StockDetailViewController") as? StockDetailViewController {
            let selectedStock = searchResults[indexPath.row]
                        vc.stockData = selectedStock
            self.navigationController?.pushViewController(vc, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "recommendedID", for: indexPath) as! RecommendedTableViewCell
            let searchResult = searchResults[indexPath.row]
            cell.configure(with: searchResult)
            return cell
        }
 
}

