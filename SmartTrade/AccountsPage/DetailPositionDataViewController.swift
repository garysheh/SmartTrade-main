//
//  DetailPositionDataViewController.swift
//  SmartTrade
//
//  Created by Frank Leung on 9/6/2024.
//

import Combine
import UIKit
import Firebase
import FirebaseFirestore
import Foundation

class DetailPositionDataViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    
    
    struct Position {
        let code: String
        var quantity: Double
        var profit: Double
    }
    
    private let db = Firestore.firestore()
    private var positions: [Position] = []
    private var stockKeys: [String] = []
    private var subscribers = Set<AnyCancellable>()
    private var searchResults: [SearchResult] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        
        calculateProfits()
        setupCardInfo()
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = tableView.bounds
        tableView.backgroundView = blurView
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return positions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "positionID", for: indexPath) as? PositionTableViewCell {
            let position = positions[indexPath.row]
            let boldFont = UIFont.boldSystemFont(ofSize: cell.profitLabel?.font.pointSize ?? 16)
            
            cell.codeLabel?.text = position.code
            cell.profitLabel?.text = "Profit: \(position.profit)"
            cell.shareLabel?.text = "Shares: \(position.quantity)"
            
            //set the bold font
            cell.profitLabel?.font = boldFont
            cell.codeLabel?.font = boldFont
            cell.shareLabel?.font = boldFont
            
            //set the color of profit
            if position.profit > 0 {
                cell.profitLabel?.textColor = .red
            } else {
                cell.profitLabel?.textColor = .green
            }
            
            cell.contentView.layer.masksToBounds = false
            //The line between two cells
            cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            
            return cell
        } else {
            // 如果转换失败,返回一个默认的 UITableViewCell
            return UITableViewCell(style: .default, reuseIdentifier: "positionID")
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "TradeHistoryViewController") as? TradeHistoryViewController {
            let selectedPosition = positions[indexPath.row]
            vc.stockSymbol = selectedPosition.code
            vc.stockPrice =  (self.searchResults.first(where: { $0.symbol == selectedPosition.code })?.price ?? "0")
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func getHoldingData(completion: @escaping ([String: (Double,Double)]) -> Void) {
        
        let db = Firestore.firestore()
        let email = Auth.auth().currentUser?.email
        var stockHoldings: [String: (Double,Double)] = [:] //the position
        
        db.collection("Holdings").document(email!).getDocument { (document, error) in
            if let document = document, document.exists {
                var holdings = document.data()?["holdings"] as? [[String: Any]] ?? []
                for holding in holdings {
                    if let stockCode = holding["stockCode"] as? String, let shares = holding["shares"] as? Double ,let avgCost = holding["avgCost"] as? Double{
                        stockHoldings[stockCode] = (shares,avgCost)
                        
                    }
                }
                completion(stockHoldings)
            } else {
                completion([:])
            }
        }
    }
    
    
    private func setupCardInfo() {
        let db = Firestore.firestore()
        guard let email = Auth.auth().currentUser?.email else {
            print("Error: email is nil")
            return
        }
        
        db.collection("UserInfo").document(email).getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error)")
                return
            }
            
            if let document = document, document.exists {
                print("yes")
                let UserID = (document.get("userID") as? Int32) ?? 0
                let name = document.get("FirstName") as? String
                
                DispatchQueue.main.async {
                    self.nameLabel.text = name ?? "N/A"
                    self.numberLabel.text = "\(UserID)"
                }
            } else {
                print("Error")
            }
            
        db.collection("Holdings").document(email).getDocument { (document, error) in
                if let error = error {
                    print("Error getting document: \(error)")
                    return
                }
                if let document = document, document.exists {
                    print("yes")
                    let balance = (document.get("balance") as? Double) ?? 0
                    var banlanceStr = String(format:"%.2f",balance)
                    
                    DispatchQueue.main.async {
                        self.balanceLabel.text = "$\(banlanceStr)"
                    }
                } else {
                    print("Error2")
                }
                
            }
            
            
        }
    }
    
    private func calculateProfits() {
        getHoldingData { holdingData in
            let apiService = APIService()
            let publishers = holdingData.keys.map { apiService.fetchSymbolsPublisher(symbol: $0) }
            self.stockKeys = Array(holdingData.keys)

            DispatchQueue.main.async {
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

                        self.positions.removeAll()
                        for (symbol, (shares,avgCost)) in holdingData {
                            if let searchResult = self.searchResults.first(where: { $0.symbol == symbol }) {
                                let currentPrice = Double(searchResult.price ?? "0") ?? 0
                                let position = Position(code: symbol, quantity: shares, profit: (round(((currentPrice-avgCost)*shares)*100)/100))
                                self.positions.append(position)
                            }
                        }
                        self.positions.sort { $0.code < $1.code }
                        self.tableView.reloadData()
                    }
                    .store(in: &self.subscribers)
            }
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

