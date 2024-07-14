//
//  OrderInputViewController.swift
//  SmartTrade
//
//  Created by Gary She on 2024/6/22.
//

import Combine
import Firebase
import FirebaseCore
import FirebaseFirestore
import Foundation
import UIKit

class OrderInputViewController: UIViewController {
    @IBOutlet weak var limitLabel: UILabel!
    @IBOutlet weak var marketLabel: UILabel!
    @IBOutlet weak var youPayField: UILabel!
    @IBOutlet weak var paymentField: UILabel!
    @IBOutlet weak var priceOrderType: UILabel!
    @IBOutlet weak var sharesLabel: UILabel!
    @IBOutlet weak var sharesAmountTextField: UITextField!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var limitOrderPriceTextField: UITextField!
    
    var currentPrice: Double?
    var stockSymbol: String?
    
    // UI INTERFACE LOGIC
    
        private var currentViewController1: UIViewController?
        private var currentViewController2: UIViewController?
        
        private var marketOrderViewController: UIViewController?
        private var limitOrderViewController: UIViewController?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupRoundedLabel(labels: [youPayField,paymentField])
            highlightMarketOrder()
            setupGestureRecognizers()
            marketOrderTapped()
        }
        
        @objc private func marketOrderTapped() {
            highlightMarketOrder()
            updateOrderTypeLabel(to: "Market Order Price")
            priceLabel.text = "\(String(format: "%.2f", currentPrice ?? 0))"
            limitOrderPriceTextField.isEnabled = false
            limitOrderPriceTextField.isHidden = true
        }

        @objc private func limitOrderTapped() {
            highlightLimitOrder()
            updateOrderTypeLabel(to: "Limit Order Price")
            priceLabel.text = ""
            limitOrderPriceTextField.isEnabled = true
            limitOrderPriceTextField.isHidden = false
        }
    
        @objc private func sharesTapped() {
            toggleAmountAndShares()
        }
        
        private func toggleAmountAndShares() {
            if amountLabel.text == "  Shares" {
                amountLabel.text = "  Amount"
            } else {
                amountLabel.text = "  Shares"
            }
        }
    
        private func updateUnitLabel(to orderType: String) {
            amountLabel.text = orderType
        }
    
        private func updateOrderTypeLabel(to orderType: String) {
            priceOrderType.text = orderType
        }
        
        private func highlightMarketOrder() {
            marketLabel.textColor = .white
            limitLabel.textColor = UIColor(red: 142/255.0, green: 142/255.0, blue: 147/255.0, alpha: 1.0) // Default color
        }
        
        private func highlightLimitOrder() {
            limitLabel.textColor = .white
            marketLabel.textColor = UIColor(red: 142/255.0, green: 142/255.0, blue: 147/255.0, alpha: 1.0) // Default color
        }
        
        private func setupGestureRecognizers() {
            let marketOrderTapGesture = UITapGestureRecognizer(target: self, action: #selector(marketOrderTapped))
            marketLabel.isUserInteractionEnabled = true
            marketLabel.addGestureRecognizer(marketOrderTapGesture)
            
            let limitOrderTapGesture = UITapGestureRecognizer(target: self, action: #selector(limitOrderTapped))
            limitLabel.isUserInteractionEnabled = true
            limitLabel.addGestureRecognizer(limitOrderTapGesture)
            
//            let sharesLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(sharesTapped))
//                    sharesLabel.isUserInteractionEnabled = true
//                    sharesLabel.addGestureRecognizer(sharesLabelTapGesture)
                    
        }
    
        private func setupRoundedLabel(labels: [UILabel]) {
            for label in labels {
                label.layer.cornerRadius = 10 // Adjust the radius as needed
                label.layer.masksToBounds = true
            }
        }
    
    // Tap the Place BUY button
    
    @IBAction func placeBuyTapped(_ sender: Any) {
        if priceOrderType.text == "Limit Order Price"{
            limitBuy()
            print("1")
        }
        else{
            marketBuy()
        }
        
    }
    
    func marketBuy(){
        if let sharesAdd = Int(sharesAmountTextField.text ?? "") {
                let db = Firestore.firestore()
                let email = Auth.auth().currentUser?.email
                var balance: Double = 0.0
                
            db.collection("Holdings").document(email!).getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    if let accountBalance = data?["balance"] as? Double {
                        balance = accountBalance
                        let purchaseAmount = (self.currentPrice ?? 0) * Double(sharesAdd)
                        print("buy:\(purchaseAmount)")
                        
                        if balance >= purchaseAmount{
                            
                            let orderUuid = UUID().uuidString
                            let timeInterval:TimeInterval = Date().timeIntervalSince1970
                            let timeStamp = Int(timeInterval)
                            let currentDate = Date()
                            
                            let newBalance = balance - purchaseAmount
                            db.collection("Holdings").document(email!).updateData(["balance": newBalance])
                            
                            
                            
                            
                            db.collection("OrdersInfo").document(email!).getDocument { (document, error) in
                                if let document = document, document.exists {
                                    var order = document.data()?["order"] as? [[String: Any]] ?? []
                                    order.append([
                                        "orderID": orderUuid,
                                        "date": currentDate,
                                        "stockCode": self.stockSymbol,
                                        "type": "buy",
                                        "quantity": sharesAdd,
                                        "price": self.currentPrice,
                                        "timestamp": timeStamp,
                                        "Status":"Done"
                                    ])
                                    db.collection("OrdersInfo").document(email!).updateData(["order": order])
                                }else{
                                    let newDocument = db.collection("OrdersInfo").document(email!)
                                    newDocument.setData([
                                        "email": email,
                                        "order": [[
                                            "orderID": orderUuid,
                                            "date": currentDate,
                                            "stockCode": self.stockSymbol,
                                            "type": "buy",
                                            "quantity": sharesAdd,
                                            "price": self.currentPrice,
                                            "timestamp": timeStamp,
                                            "Status": "Done"
                                        ]]
                                    ])
                                }
                            }
                            
                            db.collection("Holdings").document(email!).getDocument { (document, error) in
                                if let document = document, document.exists {
                                    var holdings = document.data()?["holdings"] as? [[String: Any]] ?? []
                                    
                                    // 检查是否已持有该股票
                                    var existingHolding: [String: Any]?
                                    for holding in holdings {
                                        if holding["stockCode"] as? String == self.stockSymbol {
                                            existingHolding = holding
                                            break
                                        }
                                    }
                                    
                                    if let existingHoldingIndex = holdings.firstIndex(where: { $0["stockCode"] as? String == self.stockSymbol }) {
                                        var existingHolding = holdings[existingHoldingIndex]
                                        var shares = existingHolding["shares"] as? Int ?? 0
                                        var avgCost = existingHolding["avgCost"] as? Double ?? 0.0
                                        
                                        // 更新平均持仓成本
                                        if let stockPrice = self.currentPrice {
                                            let newTotalCost = (Double(shares) * avgCost) + (Double(sharesAdd) * stockPrice)
                                            let newTotalShares = shares + sharesAdd
                                            avgCost = newTotalCost / Double(newTotalShares)
                                        } else {
                                            // 處理 Stockprice.text 無法轉換為 Double 的情況
                                            let newTotalCost = (Double(shares) * avgCost) + (Double(sharesAdd) * 0.0)
                                            let newTotalShares = shares + sharesAdd
                                            avgCost = newTotalCost / Double(newTotalShares)
                                        }
                                        
                                        shares += sharesAdd
                                        avgCost = round(avgCost * 100) / 100
                                        
                                        existingHolding["shares"] = shares
                                        existingHolding["avgCost"] = avgCost
                                        holdings[existingHoldingIndex] = existingHolding
                                        
                                        // update the records
                                        db.collection("Holdings").document(email!).updateData([
                                            "holdings": holdings
                                        ])
                                    } else {
                                        // adding the new record
                                        holdings.append([
                                            "stockCode": self.stockSymbol,
                                            "shares": sharesAdd,
                                            "avgCost": Double(self.currentPrice ?? 0)
                                        ])
                                        
                                        // update in Firestore
                                        db.collection("Holdings").document(email!).updateData([
                                            "holdings": holdings
                                        ])
                                    }
                                } else {
                                    // create a new holding stock index
                                    db.collection("Holdings").document(email!).setData([
                                        "email": email,
                                        "holdings": [
                                            ["stockCode": self.stockSymbol, "shares": sharesAdd, "avgCost": Double(self.currentPrice ?? 0)]
                                        ]
                                    ])
                                }
                                if let vc = self.storyboard?.instantiateViewController(identifier: "PlaceSuccessfullyViewController") as? PlaceSuccessfullyViewController {
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }
                            }
                        }else{
                            let alert = UIAlertController(title: "Oops..", message: "You don't have enough balance!", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK👌", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    } else {
                        print("Balance property not found")
                    }
                } else {
                    print("Document does not exist")
                }
            }
        } else {
            let alert = UIAlertController(title: "Oops..", message: "Not a correct share amount! Please check the amount.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK👌", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func limitBuy(){
        if let sharesAdd = Int(sharesAmountTextField.text ?? ""){
            if let limitPrice = Double(limitOrderPriceTextField.text ?? "") {
                if limitPrice < currentPrice ?? 0{
                    let db = Firestore.firestore()
                    let orderUuid = UUID().uuidString
                    let timeInterval:TimeInterval = Date().timeIntervalSince1970
                    let timeStamp = Int(timeInterval)
                    let currentDate = Date()
                    let email = Auth.auth().currentUser?.email
                    db.collection("OrdersInfo").document(email!).getDocument { (document, error) in
                            if let document = document, document.exists {
                                var order = document.data()?["order"] as? [[String: Any]] ?? []
                                order.append([
                                    "orderID": orderUuid,
                                    "date": currentDate,
                                    "stockCode": self.stockSymbol,
                                    "type": "buy",
                                    "quantity": sharesAdd,
                                    "price": limitPrice,
                                    "timestamp": timeStamp,
                                    "Status":"Waiting"
                                ])
                                db.collection("OrdersInfo").document(email!).updateData(["order": order])
                            }else{
                                let newDocument = db.collection("OrdersInfo").document(email!)
                                    newDocument.setData([
                                        "email": email,
                                        "order": [[
                                            "orderID": orderUuid,
                                            "date": currentDate,
                                            "stockCode": self.stockSymbol,
                                            "type": "buy",
                                            "quantity": sharesAdd,
                                            "price": limitPrice,
                                            "timestamp": timeStamp,
                                            "Status":"Waiting"
                                        ]]
                                    ])
                            }
                        //ToDo: to process the order.
                        
                        let alert = UIAlertController(title: "Order made!💰", message: "Waiting for CCP processing. . .", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK👌", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                    
                }else{
                    let alert = UIAlertController(title: "Oops..", message: "Not a correct Price! Please check.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK👌", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }else{
                let alert = UIAlertController(title: "Oops..", message: "Not a correct Price! Please check.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK👌", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }else{
            let alert = UIAlertController(title: "Oops..", message: "Not a correct share amount! Please check the amount.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK👌", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    // BUY AND SELL PART

}
