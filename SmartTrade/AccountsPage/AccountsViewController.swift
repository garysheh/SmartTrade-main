//
//  AccountsViewController.swift
//  SmartTrade
//
//  Created by Gary She on 2024/6/1.
//

import UIKit
import Combine
import Charts
import DGCharts
import Firebase
import FirebaseCore
import FirebaseFirestore
import Foundation

class AccountsViewController: UIViewController {

    
    @IBOutlet weak var ChartsView: UIView!
    
    @IBOutlet weak var shareCounts: UILabel!
    
    @IBOutlet weak var marketValue: UILabel!
    
    @IBOutlet weak var costValue: UILabel!
    
    @IBOutlet weak var portRate: UILabel!
    
//    @IBOutlet weak var todayReturnRate: UILabel!
//    
//    @IBOutlet weak var todayReturnValue: UILabel!
    
    @IBOutlet weak var totalReturnValue: UILabel!
    
    @IBOutlet weak var totalReturnRate: UILabel!
    
    @IBOutlet weak var detailButton: UIButton!
    
    
    struct Position {
        let code: String
        var quantity: Double
        var profit: Double
    }
    
    
    
//    private var stockData: [String: Double] = [:]
    private var stockKeys: [String] = []
    private var positions: [Position] = []
    private var subscribers = Set<AnyCancellable>()
    private var searchResults: [SearchResult] = []
    
    let cusColors: [UIColor] = [
        UIColor(red: 13/255.0, green: 126/255.0, blue: 156/255.0, alpha: 1.0),
        UIColor(red: 24/255.0, green: 90/255.0, blue: 86/255.0, alpha: 1.0),
        UIColor(red: 253/255.0, green: 116/255.0, blue: 45/255.0, alpha: 1.0),
        UIColor(red: 83/255.0, green: 88/255.0, blue: 154/255.0, alpha: 1.0),
        UIColor(red: 251/255.0, green: 205/255.0, blue: 8/255.0, alpha: 1.0),
        UIColor(red: 54/255.0, green: 54/255.0, blue: 54/255.0, alpha: 1.0),
        UIColor(red: 127/255.0, green: 169/255.0, blue: 31/255.0, alpha: 1.0),
        UIColor(red: 213/255.0, green: 186/255.0, blue: 159/255.0, alpha: 1.0),
        UIColor(red: 0/255.0, green: 50/255.0, blue: 77/255.0, alpha: 1.0),
        UIColor(red: 184/255.0, green: 144/255.0, blue: 118/255.0, alpha: 1.0),
        UIColor(red: 220/255.0, green: 60/255.0, blue: 20/255.0, alpha: 1.0),
        UIColor(red: 0/255.0, green: 206/255.0, blue: 209/255.0, alpha: 1.0)
    ]
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupChartsData()
        setTotalCounts()
        }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    

    //get the data from the database
    private func getHoldingData(completion: @escaping ([String: (Double,Double)], Double, Double) -> Void) {
        let db = Firestore.firestore()
        let email = Auth.auth().currentUser?.email
        var stockHoldings: [String: (Double,Double)] = [:] //the position
        var cost: Double = 0
        var myreturn: Double = 0
        
        db.collection("Holdings").document(email!).getDocument { (document, error) in
            if let document = document, document.exists {
                var holdings = document.data()?["holdings"] as? [[String: Any]] ?? []
                for holding in holdings {
                    if let stockCode = holding["stockCode"] as? String, let shares = holding["shares"] as? Double, let avgCost = holding["avgCost"] as? Double {
                        stockHoldings[stockCode] = (shares,avgCost)
                    }
                }
                
                if let costData = document.data()?["cost"] as? Double {
                    cost = costData
                }
                
                if let returnData = document.data()?["return"] as? Double {
                    myreturn = returnData
                }
                
                completion(stockHoldings, cost, myreturn)
            } else {
                completion([:], 0, 0)
            }
        }
    }
    
    
    //update the chart when entering this page
    private func setupChartsData() {
        // clean the chart before
        ChartsView.subviews.forEach { $0.removeFromSuperview() }

        // update the chart and data
        getHoldingData { holdingData ,cost, myreturn in
            self.drawPieChart(with: holdingData)
            
        }
    }
    
    

    private func drawPieChart(with holdingData: [String: (Double,Double)]) {
        
        //draw the chart
        let pieChartView = PieChartView(frame: ChartsView.bounds)
        ChartsView.addSubview(pieChartView)

        var dataEntries: [PieChartDataEntry] = []
        for (symbol, (shares,avgCost)) in holdingData {
            dataEntries.append(PieChartDataEntry(value: shares, label: symbol))
        }

        let dataSet = PieChartDataSet(entries: dataEntries)
        dataSet.colors = self.cusColors
        pieChartView.holeColor = .black
        dataSet.valueColors = [.white]
        pieChartView.legend.enabled = false
        let pieChartData = PieChartData(dataSet: dataSet)
        pieChartView.data = pieChartData
        
    }
    
    
    //update the sharescount
    private func setupShareCounts(){
        
        getHoldingData { holdingData, cost, myreturn in
            //set the share count
            let totalShares = holdingData.values.reduce(0) { $0 + $1.0 }
            self.shareCounts.text = String(format: "%.2f", Double(totalShares))
            // self.shareCounts.text = "\(totalShares)"
            // align the text to be centered
            self.shareCounts.textAlignment = .center
        }
    }
    
    private func calculateTotalValue() {
        getHoldingData { holdingData , cost, myreturn in
            let apiService = APIService()
            let publishers = holdingData.keys.map { apiService.fetchSymbolsPublisher(symbol: $0) }
            var stockValues: [String: Double] = [:]
            self.stockKeys = Array(holdingData.keys)
            
            
             
            DispatchQueue.main.async {
                
                

                let publishers = self.stockKeys.map { apiService.fetchSymbolsPublisher(symbol: $0) }
                
                Publishers.MergeMany(publishers)
                    .map { data -> SearchResult? in
                        if let searchResults = try? JSONDecoder().decode(SearchResults.self, from: data) {
                            return searchResults.globalQuote
                        }
                        return nil
                    }
                    .collect()
                    .receive(on: RunLoop.main)
                    .sink { completion in
                        switch completion {
                        case .failure(let error):
                            print(error.localizedDescription)
                        case .finished:
                            break
                        }
                    } receiveValue: { searchResults in
                        self.searchResults = searchResults.compactMap { $0 }
                        
                        // Calculate the total value
                        var totalValue: Double = 0
                        for (symbol, (shares,avgCost)) in holdingData {
                            if let searchResult = self.searchResults.first(where: { $0.symbol == symbol }) {
                                let currentPrice = Double(searchResult.price ?? "0") ?? 0
                                let value = Double(shares) * currentPrice
                                totalValue += value
                                stockValues[symbol] = value
                            }
                        }
                        
                        // Set the total value text
                        self.marketValue.text = String(format: "%.2f", totalValue)
                        self.marketValue.textAlignment = .right
                        print("Stock Values: \(stockValues)")
                    }
                    .store(in: &self.subscribers)
            }
            
        }
    }
    
    
    private func calculateSumProfits() {
        getHoldingData { holdingData , cost, myreturn in
            let apiService = APIService()
            let publishers = holdingData.keys.map { apiService.fetchSymbolsPublisher(symbol: $0) }
            self.stockKeys = Array(holdingData.keys)
            var returnRate : Double = 0
            
            
            DispatchQueue.main.async {
                
                let publishers = self.stockKeys.map { apiService.fetchSymbolsPublisher(symbol: $0) }
                
                Publishers.MergeMany(publishers)
                    .map { data -> SearchResult? in
                        if let searchResults = try? JSONDecoder().decode(SearchResults.self, from: data) {
                            return searchResults.globalQuote
                        }
                        return nil
                    }
                    .collect()
                    .receive(on: RunLoop.main)
                    .sink { completion in
                        switch completion {
                        case .failure(let error):
                            print(error.localizedDescription)
                        case .finished:
                            break
                        }
                    } receiveValue: { searchResults in
                        self.searchResults = searchResults.compactMap { $0 }
                        
                        var ProfitSum: Double = 0
                        for (symbol, (shares,avgCost)) in holdingData {
                            if let searchResult = self.searchResults.first(where: { $0.symbol == symbol }) {
                                let currentPrice = Double(searchResult.price ?? "0") ?? 0
                                let position = Position(code: symbol, quantity: shares, profit: (round(((currentPrice-avgCost)*shares)*100)/100))
                                ProfitSum += position.profit
                            }
                        }
                        print(ProfitSum)
                        returnRate = (myreturn + ProfitSum)/cost * 100
                        var returnRateStr = String(format:"%.2f",returnRate)
                        var ProfitSumStr = String(format:"%.2f",ProfitSum)
                        self.totalReturnValue.text = "\(ProfitSumStr)"
                        self.totalReturnRate.text = "\(returnRateStr)%"
                    
                    }
                    .store(in: &self.subscribers)
            }
        }
    }
    
    private func setTotalCounts(){
        setupShareCounts()
        
        calculateSumProfits()
        
        calculateTotalValue()
    }
    


    
    
    
    
    
    
    
    


    @IBAction func detailButtonTapped(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(identifier: "DetailPositionDataViewController") as? DetailPositionDataViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


}
