//
//  WatchListViewController.swift
//  SmartTrade
//
//  Created by Gary She on 2024/5/25.
//

import UIKit
import Combine
import Firebase
import FirebaseCore
import FirebaseFirestore
import Foundation

class WatchListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchButton: UIButton!
    
    private let apiService = APIService()
    private var subscribers = Set<AnyCancellable>()
    private var searchResults: [SearchResult] = []
    @Published private var searchQuery = String()
    var emailID: String = ""
    var symbols = ["IBM", "AAPL", "GOOGL", "AMZN", "NDAQ", "MSFT"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tabBarController?.selectedIndex = 0
//        updateSymbol()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSymbol()
    }

    private func updateSymbol() {
        let db = Firestore.firestore()
        guard let email = Auth.auth().currentUser?.email else {
            print("Error: email is nil")
            return
        }
        
        db.collection("Watchlist").document(email).getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error)")
                return
            }
            
            if let document = document, document.exists {
                let lists = document.data()?["watchlist"] as? [String] ?? []
                DispatchQueue.main.async {
                    self.symbols = lists
                    self.searchResults.removeAll()
                    self.performSearch()
                }
            } else {
                // Watchlist does not exist, create a new one with the default symbols
                db.collection("Watchlist").document(email).setData(["watchlist": self.symbols]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                        DispatchQueue.main.async {
                            self.searchResults.removeAll()
                            self.performSearch()
                        }
                    }
                }
            }
        }
    }
    
    
    private func performSearch() {
//            let symbols = ["IBM", "AAPL", "GOOGL", "AMZN", "NDAQ", "MSFT"]
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
        return 85;//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "StockDetailViewController") as? StockDetailViewController {
                let selectedStock = searchResults[indexPath.row]
                vc.stockSymbol = selectedStock.symbol
                vc.stockData = selectedStock
                self.navigationController?.pushViewController(vc, animated: true)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "stockId", for: indexPath) as! StockTableViewCell
            let searchResult = searchResults[indexPath.row]
            cell.configure(with: searchResult)
            return cell
        }
    
    @IBAction func searchClicked(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(identifier: "SearchTableViewController") as? SearchTableViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
 
}
