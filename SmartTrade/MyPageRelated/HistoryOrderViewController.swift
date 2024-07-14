//
//  HistoryOrderViewController.swift
//  SmartTrade
//
//  Created by Frank Leung on 9/7/2024.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore

class HistoryOrderViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var typeOrderSelected: UISegmentedControl!
    @IBOutlet weak var TableView: UITableView!
    

    var orderData: [(symbol: String, date: String, price: Double, type: String,shares: Int)] = []
    var showCompletedOrders = true
    var orderCompletedData: [(symbol: String, date: String, price: Double, type: String,shares: Int)] = []
    var orderIncompletedData: [(symbol: String, date: String, price: Double, type: String,shares: Int)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TableView.delegate = self
        TableView.dataSource = self
        // Do any additional setup after loading the view.
        
        get2kindsList()
        orderData = orderCompletedData
        TableView.reloadData()

        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "orderID", for: indexPath) as? OrderTableViewCell else {
            return UITableViewCell()
        }
        
        let order = orderData[indexPath.row]
        cell.stockSymbol.text = order.symbol + "--\(order.shares) Shares"
        cell.orderDate.text = order.date
        cell.stockPrice.text = "$"+String(format: "%.2f",order.price)
        cell.orderType.text = order.type.uppercased()
        
        cell.layer.cornerRadius = 8.0
        cell.layer.masksToBounds = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 处理用户选择单元格的逻辑
        let order = orderData[indexPath.row]
        print("用户选择了 \(order.symbol) 的订单\(order.shares), 日期: \(order.date), 价格: \(order.price)")
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100;//Choose your custom row height
    }
    
    
    @IBAction func typeOrderOptionSwitch(_ sender: UISegmentedControl) {
        // 处理选中选项变化的逻辑
        switch sender.selectedSegmentIndex {
        case 0:
            //check the completed orders
            showCompletedOrders = true
        case 1:
            //check the incompleted orders
            showCompletedOrders = false
        default:
            break
        }
        
        updateOrderData()
        TableView.reloadData()
    }
    
    func updateOrderData() {
        if showCompletedOrders {
            // Get completed orders data
            orderData.removeAll()
            orderData = orderCompletedData
        } else {
            // Get incomplete orders data
            orderData.removeAll()
            orderData = orderIncompletedData
        }
    }


    
    func get2kindsList(){
        orderCompletedData.removeAll()
        orderIncompletedData.removeAll()
        getCompeletedData {
            DispatchQueue.main.async {
                self.orderData = self.orderCompletedData
                self.TableView.reloadData()
            }
        }
        getIncompeletedData {
            
        }

        
        
    }
    

    private func getCompeletedData(completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        guard let email = Auth.auth().currentUser?.email else {
            print("Error: Current user's email is nil")
            completion()
            return
        }
        
        db.collection("OrdersInfo").document(email).getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error)")
                completion()
                return
            }
            
            if let document = document, document.exists {
                var orders = document.data()?["order"] as? [[String: Any]] ?? []
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                
                for order in orders.reversed() {
                    if let stockCode = order["stockCode"] as? String,
                       let shares = order["quantity"] as? Int,
                       let price = order["price"] as? Double,
                       let status = order["Status"] as? String,
                       let type = order["type"] as? String,
                       let date = order["date"] as? Timestamp {
                        if status == "Done" {
                            let dateString = dateFormatter.string(from: date.dateValue())
                            self.orderCompletedData.append((symbol: stockCode, date: dateString, price: price, type: type,shares: shares))
                        }
                    }
                }
                completion()
            } else {
                print("No document found for user: \(email)")
                completion()
            }
        }
    }
    
    private func getIncompeletedData(completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        guard let email = Auth.auth().currentUser?.email else {
            print("Error: Current user's email is nil")
            completion()
            return
        }
        
        db.collection("OrdersInfo").document(email).getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error)")
                completion()
                return
            }
            
            if let document = document, document.exists {
                var orders = document.data()?["order"] as? [[String: Any]] ?? []
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                
                for order in orders.reversed() {
                    if let stockCode = order["stockCode"] as? String,
                       let shares = order["quantity"] as? Int,
                       let price = order["price"] as? Double,
                       let status = order["Status"] as? String,
                       let type = order["type"] as? String,
                       let date = order["date"] as? Timestamp {
                        if status == "Waiting" {
                            let dateString = dateFormatter.string(from: date.dateValue())
                            self.orderIncompletedData.append((symbol: stockCode, date: dateString, price: price, type: type,shares: shares))
                        }
                    }
                }
                completion()
            } else {
                print("No document found for user: \(email)")
                completion()
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
