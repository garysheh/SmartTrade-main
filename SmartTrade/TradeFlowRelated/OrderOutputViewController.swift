//
//  OrderOutputViewController.swift
//  SmartTrade
//
//  Created by Gary She on 2024/6/27.
//

import UIKit
import Firebase
import FirebaseFirestore
import Foundation

class OrderOutputViewController: UIViewController {
    
    @IBOutlet weak var OutputLimitOrder: UILabel!
    @IBOutlet weak var OutputMarketOrder: UILabel!
    @IBOutlet weak var balanceField: UILabel!
    @IBOutlet weak var availableShareField: UILabel!
    @IBOutlet weak var outputAmountLabel: UILabel!
    @IBOutlet weak var outputOrderTypeLabel: UILabel!
    @IBOutlet weak var outputTotalLabel: UILabel!
    @IBOutlet weak var outputSharesForBottomLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var LimitOrderPriceTextField: UITextField!
    @IBOutlet weak var sharesAmoutTextField: UITextField!
    @IBOutlet weak var outputpriceLabel: UILabel!
    
    var currentPrice: Double?
    var stockSymbol: String?
    var holdingShare: Int?
    
    
    // UI INTERFACE LOGIC
    
        private var currentViewController1: UIViewController?
        private var currentViewController2: UIViewController?
        
        private var marketOrderViewController: UIViewController?
        private var limitOrderViewController: UIViewController?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupRoundedLabel(labels: [balanceField,availableShareField])
            highlightMarketOrder()
            setupGestureRecognizers()
            updateInfo()
            marketOrderTapped()
            
        }
        
        @objc private func marketOrderTapped() {
            highlightMarketOrder()
            updateOrderTypeLabel(to: "Market Order Price")
            priceLabel.text = "\(String(format: "%.2f", currentPrice ?? 0))"
            LimitOrderPriceTextField.isEnabled = false
            LimitOrderPriceTextField.isHidden = true
        }

        @objc private func limitOrderTapped() {
            highlightLimitOrder()
            updateOrderTypeLabel(to: "Limit Order Price")
            priceLabel.text = ""
            LimitOrderPriceTextField.isEnabled = true
            LimitOrderPriceTextField.isHidden = false
        }
    
        @objc private func sharesTapped() {
            toggleAmountAndShares()
        }
        
        private func toggleAmountAndShares() {
            if outputAmountLabel.text == "  Shares" {
                outputAmountLabel.text = "  Amount"
                
            } else {
                
            }
        }
    
        private func updateUnitLabel(to orderType: String) {
            outputAmountLabel.text = orderType
        }
    
        private func updateOrderTypeLabel(to orderType: String) {
            outputOrderTypeLabel.text = orderType
        }
        
        private func highlightMarketOrder() {
            OutputMarketOrder.textColor = .white
            OutputLimitOrder.textColor = UIColor(red: 142/255.0, green: 142/255.0, blue: 147/255.0, alpha: 1.0) // Default color
        }
        
        private func highlightLimitOrder() {
            OutputLimitOrder.textColor = .white
            OutputMarketOrder.textColor = UIColor(red: 142/255.0, green: 142/255.0, blue: 147/255.0, alpha: 1.0) // Default color
        }
        
        private func setupGestureRecognizers() {
            let marketOrderTapGesture = UITapGestureRecognizer(target: self, action: #selector(marketOrderTapped))
            OutputMarketOrder.isUserInteractionEnabled = true
            OutputMarketOrder.addGestureRecognizer(marketOrderTapGesture)
            
            let limitOrderTapGesture = UITapGestureRecognizer(target: self, action: #selector(limitOrderTapped))
            OutputLimitOrder.isUserInteractionEnabled = true
            OutputLimitOrder.addGestureRecognizer(limitOrderTapGesture)
            
//            let sharesLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(sharesTapped))
//            outputSharesLabel.isUserInteractionEnabled = true
//            outputSharesLabel.addGestureRecognizer(sharesLabelTapGesture)
//                    
//                    let sharesIconTapGesture = UITapGestureRecognizer(target: self, action: #selector(sharesTapped))
//            outputSharesIcon.isUserInteractionEnabled = true
//            outputSharesIcon.addGestureRecognizer(sharesIconTapGesture)
        }
    
        private func setupRoundedLabel(labels: [UILabel]) {
            for label in labels {
                label.layer.cornerRadius = 10 // Adjust the radius as needed
                label.layer.masksToBounds = true
            }
        }
    
    
    @IBAction func placeSellTapped(_ sender: Any) {
        if outputOrderTypeLabel.text == "Limit Order Price"{
            limitSell()
        }
        else{
            marketSell()
        }
    }
    
    func marketSell(){
        if let sharesAdd = Int(sharesAmoutTextField.text ?? "")
        {
            let db = Firestore.firestore()
            let orderUuid = UUID().uuidString
            let timeInterval:TimeInterval = Date().timeIntervalSince1970
            let timeStamp = Int(timeInterval)
            let currentDate = Date()
            let email = Auth.auth().currentUser?.email
            var balanceAdd: Double = 0.0
            var balance: Double = 0.0


            
            db.collection("OrdersInfo").document(email!).getDocument { [self] (document, error) in
                if let document = document, document.exists {
                    var order = document.data()?["order"] as? [[String: Any]] ?? []
                    order.append([
                        "orderID": orderUuid,
                        "date": currentDate,
                        "stockCode": self.stockSymbol,
                        "type": "sell",
                        "quantity": sharesAdd,
                        "price":self.currentPrice ,
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
                                "type": "sell",
                                "quantity": sharesAdd,
                                "price": self.currentPrice,
                                "timestamp": timeStamp,
                                "Status":"Done"
                            ]]
                        ])
                }
            }

            
            db.collection("Holdings").document(email!).getDocument { (document, error) in
                    if let document = document, document.exists {
                        var holdings = document.data()?["holdings"] as? [[String: Any]] ?? []
                        
                        // 检查是否已持有该股票
                        if let existingHoldingIndex = holdings.firstIndex(where: { $0["stockCode"] as? String == self.stockSymbol }) {
                            var existingHolding = holdings[existingHoldingIndex]
                            var shares = existingHolding["shares"] as? Int ?? 0
                            var avgCost = existingHolding["avgCost"] as? Double ?? 0.0
                            
                            // 如果持有股数大于等于要卖出的数量
                            if shares >= sharesAdd {
                                
                                let totalValue = Double(shares) * avgCost
                                shares -= sharesAdd
                                let sharesAddDouble = Double(sharesAdd)
                                let currentPriceDouble = Double(self.currentPrice ?? 0)
                                let sharesDouble = Double(shares)
                                let newAvgCost = (totalValue - (sharesAddDouble * currentPriceDouble)) / sharesDouble
                                balanceAdd = Double(sharesAdd) * currentPriceDouble
                                
                                db.collection("Holdings").document(email!).getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        let data = document.data()
                                        if let accountBalance = data?["balance"] as? Double {
                                            balance = accountBalance}}
                                    
                                    
                                    let newBalance = balance + balanceAdd
                                    db.collection("Holdings").document(email!).updateData(["balance": newBalance])
                                    
                                }
                                
                                
                                existingHolding["avgCost"] = round(newAvgCost * 100) / 100
                                existingHolding["shares"] = shares
                                
                                
                                // 如果卖出后股票数量为 0,从持仓列表中删除
                                if shares == 0 {
                                    holdings.remove(at: existingHoldingIndex)
                                } else {
                                    holdings[existingHoldingIndex] = existingHolding
                                }
                                
                                // 更新持仓信息到 Firestore
                                db.collection("Holdings").document(email!).updateData([
                                    "holdings": holdings
                                ])
                                if let vc = self.storyboard?.instantiateViewController(identifier: "PlaceSuccessfullyViewController") as? PlaceSuccessfullyViewController {
                                        self.navigationController?.pushViewController(vc, animated: true)
                                }

                            } else {
                                let alert = UIAlertController(title: "It doesn't look good...", message: "It seems you don't hold enough shares.", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK👌", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        } else {
                            let alert = UIAlertController(title: "Oh...", message: "You do not own this stock.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK👌", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)

                        }
                    } else {
                        let alert = UIAlertController(title: "Sorry!🧎", message: "You do not own holdings.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK👌", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                                                              }
        }
    }
    
    func limitSell(){
        if let sharesAdd = Int(sharesAmoutTextField.text ?? ""){
            if let limitPrice = Double(LimitOrderPriceTextField.text ?? ""){
                if limitPrice > currentPrice ?? 0{
                    let db = Firestore.firestore()
                    let orderUuid = UUID().uuidString
                    let timeInterval:TimeInterval = Date().timeIntervalSince1970
                    let timeStamp = Int(timeInterval)
                    let currentDate = Date()
                    let email = Auth.auth().currentUser?.email
                    
                        db.collection("Holdings").document(email!).getDocument { (document, error) in
                            if let document = document, document.exists {
                                var holdings = document.data()?["holdings"] as? [[String: Any]] ?? []
                                
                                // 检查是否已持有该股票
                                if let existingHoldingIndex = holdings.firstIndex(where: { $0["stockCode"] as? String == self.stockSymbol }) {
                                    var existingHolding = holdings[existingHoldingIndex]
                                    var shares = existingHolding["shares"] as? Int ?? 0
                                    
                                    // 如果持有股数大于等于要卖出的数量
                                    if shares >= sharesAdd {
                                        
                                        
                                        db.collection("OrdersInfo").document(email!).getDocument { (document, error) in
                                            if let document = document, document.exists {
                                                var order = document.data()?["order"] as? [[String: Any]] ?? []
                                                order.append([
                                                    "orderID": orderUuid,
                                                    "date": currentDate,
                                                    "stockCode": self.stockSymbol,
                                                    "type": "sell",
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
                                                            "type": "sell",
                                                            "quantity": sharesAdd,
                                                            "price": limitPrice,
                                                            "timestamp": timeStamp,
                                                            "Status":"Waiting"
                                                        ]]
                                                    ])
                                            }
                                        }
                                        
                                        if let vc = self.storyboard?.instantiateViewController(identifier: "PlaceSuccessfullyViewController") as? PlaceSuccessfullyViewController {
                                                self.navigationController?.pushViewController(vc, animated: true)
                                            }
                                        
                                        
                                        
                                    } else {
                                        let alert = UIAlertController(title: "It doesn't look good...", message: "It seems you don't hold enough shares.", preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "OK👌", style: .default, handler: nil))
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                } else {
                                    let alert = UIAlertController(title: "Oh...", message: "You do not own this stock.", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "OK👌", style: .default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                    if let vc = self.storyboard?.instantiateViewController(identifier: "PlaceFailedViewController") as? PlaceFailedViewController {
                                            self.navigationController?.pushViewController(vc, animated: true)
                                    }
                                }
                            } else {
                                let alert = UIAlertController(title: "Sorry!🧎", message: "You do not own holdings.", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK👌", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                }
                else{
                    let alert = UIAlertController(title: "Oops..", message: "Not a correct price! Please check.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK👌", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }else{
                let alert = UIAlertController(title: "Oops..", message: "Not a correct price! Please check.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK👌", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        else{
            let alert = UIAlertController(title: "Oops..", message: "Not a correct share amount! Please check the amount.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK👌", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
//    if let vc = storyboard?.instantiateViewController(identifier: "PlaceSuccessfullyViewController") as? PlaceSuccessfullyViewController {
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
    func updateInfo(){
        let db = Firestore.firestore()
        guard let email = Auth.auth().currentUser?.email else {
            print("Error: email is nil")
            return
        }
        db.collection("Holdings").document(email).getDocument { (document, error) in
                if let error = error {
                    print("Error getting document: \(error)")
                    return
                }
                if let document = document, document.exists {
                    print("yes")
                    var holdings = document.data()?["holdings"] as? [[String: Any]] ?? []
                    for holding in holdings {
                        if let stockCode = holding["stockCode"] as? String, let shares = holding["shares"] as? Double {
                            if stockCode == self.stockSymbol{
                                self.holdingShare = Int(shares)
                            }
                        }
                    }
                    
                    DispatchQueue.main.async {
                        if let shares = self.holdingShare {
                            self.outputTotalLabel.text = "\(shares) shares available"
                        } else {
                            self.outputTotalLabel.text = "No data available"
                        }
                    }
                } else {
                    print("Error2")
                }
            }
        }
    
    
    // BUY AND SELL PART

}
