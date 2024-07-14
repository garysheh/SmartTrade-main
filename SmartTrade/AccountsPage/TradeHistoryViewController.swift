//
//  TradeHistoryViewController.swift
//  SmartTrade
//
//  Created by Frank Leung on 25/6/2024.
//


import UIKit
import Firebase
import DGCharts
import FirebaseCore
import FirebaseFirestore

class TradeHistoryViewController: UIViewController {
    
    var tabBarIndex: Int?
    var stockSymbol: String?
    var stockPrice: String?
    var stockData: [TradeOrder] = []
    
    
    @IBOutlet weak var ShowLineSwitch: UISwitch!
    @IBOutlet weak var ChartView: UIView!
    private var currentBarChartView: BarChartView?
    var targetLine : ChartLimitLine?
    var currentPrice: Double?
    
    
    
    
    struct TradeOrder: Codable {
        let symbol: String
        let quantity: Double
        let timestamp: Timestamp
        let email: String
        let type: String
    }
    
    let segmentedControl = UISegmentedControl(items: ["Buy", "Sell"])
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSegmentedControl()
        }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLine()
        setBarChartBuy()
    }
    
    private func setupLine(){
        if let price = Double(self.stockPrice ?? "") {
            currentPrice = price
//            print(currentPrice)
        } else {
            print("cannot get the price")
        }
    }
    
    //setting the segmented controller
    private func setupSegmentedControl() {
            segmentedControl.selectedSegmentIndex = 0
            view.addSubview(segmentedControl)
            
            // add constraint
            segmentedControl.translatesAutoresizingMaskIntoConstraints = false
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60).isActive = true
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
            
            // set style
            segmentedControl.backgroundColor = .black
            segmentedControl.selectedSegmentTintColor = .systemGreen
            let font = UIFont.systemFont(ofSize: 16, weight: .medium)
            segmentedControl.setTitleTextAttributes([.font: font, .foregroundColor: UIColor.white], for: .normal)
            segmentedControl.setTitleTextAttributes([.font: font, .foregroundColor: UIColor.white], for: .selected)
            
            segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        }
    
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
            // 处理选中选项变化的逻辑
            switch sender.selectedSegmentIndex {
            case 0:
                if let currentBarChartView = currentBarChartView {
                        currentBarChartView.removeFromSuperview()
                    }
                setBarChartBuy()
            case 1:
                if let currentBarChartView = currentBarChartView {
                        currentBarChartView.removeFromSuperview()
                    }
                setBarChartSell()
            default:
                break
            }
        }
    
    
    //----------------------------------- sell ----------------------------------
    private func setBarChartBuy() {
        getBuy5Data { buyData in
            let barChartView = BarChartView(frame: self.ChartView.bounds)
//            let categories = buyData.sorted { $0.key < $1.key }.map { "\($0.key + 1)" }
            let shares = buyData.map {"\($0.value.0) shares"}
            let data = buyData.sorted { $0.key < $1.key }.reversed().map { $0.value.1 }
            
            let dataSet = BarChartDataSet(entries: data.enumerated().map { BarChartDataEntry(x: Double($0.offset), y: $0.element) }, label: " ")
            dataSet.colors = [UIColor.systemBlue]
            dataSet.valueColors = [.white]
            dataSet.valueFont = .systemFont(ofSize: 12)
            
            let chartData = BarChartData(dataSet: dataSet)
            chartData.barWidth = 0.5
            
            barChartView.data = chartData
            barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: shares)
            barChartView.xAxis.granularity = 1
            barChartView.xAxis.labelPosition = .bottom
            barChartView.leftAxis.axisMinimum = 0
            barChartView.leftAxis.axisMaximum = (buyData.values.map { $0.1 }.max() ?? 350) + 50
            barChartView.leftAxis.labelCount = 6
            
            barChartView.xAxis.labelTextColor = UIColor.white
            barChartView.leftAxis.labelTextColor = UIColor.white
            
            barChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .linear)
            
            if self.ShowLineSwitch.isOn {
                let targetLine = ChartLimitLine(limit: self.currentPrice ?? 0, label: "Current Price:\(self.currentPrice ?? 0)")
                targetLine.lineColor = UIColor.green
                targetLine.lineWidth = 1.5
                targetLine.valueTextColor = UIColor.green
                targetLine.valueFont = .systemFont(ofSize: 10)
                barChartView.leftAxis.addLimitLine(targetLine)
            }

            self.currentBarChartView = barChartView
            self.ChartView.addSubview(barChartView)
            
        }
    }

    private func setBarChartSell() {
        getSell5Data { sellData in
            let barChartView = BarChartView(frame: self.ChartView.bounds)
//            let categories = sellData.sorted { $0.key < $1.key }.map { "\($0.key + 1)" }
            let shares = sellData.map {"\($0.value.0) shares"}
            let data = sellData.sorted { $0.key < $1.key }.reversed().map { $0.value.1 }
            
            let dataSet = BarChartDataSet(entries: data.enumerated().map { BarChartDataEntry(x: Double($0.offset), y: $0.element) }, label: " ")
            dataSet.colors = [UIColor.systemRed]
            dataSet.valueColors = [.white]
            dataSet.valueFont = .systemFont(ofSize: 12)
            
            let chartData = BarChartData(dataSet: dataSet)
            chartData.barWidth = 0.5
            
            barChartView.data = chartData
            barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: shares)
            barChartView.xAxis.granularity = 1
            barChartView.xAxis.labelPosition = .bottom
            barChartView.leftAxis.axisMinimum = 0
            barChartView.leftAxis.axisMaximum = (sellData.values.map { $0.1 }.max() ?? 350) + 50
            barChartView.leftAxis.labelCount = 6
            
            barChartView.xAxis.labelTextColor = UIColor.white
            barChartView.leftAxis.labelTextColor = UIColor.white
            
            barChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .linear)
            
            if self.ShowLineSwitch.isOn {
                let targetLine = ChartLimitLine(limit: self.currentPrice ?? 0, label: "Current Price:\(self.currentPrice ?? 0)")
                targetLine.lineColor = UIColor.green
                targetLine.lineWidth = 1.5
                targetLine.valueTextColor = UIColor.green
                targetLine.valueFont = .systemFont(ofSize: 10)
                barChartView.leftAxis.addLimitLine(targetLine)
            }
            
            self.currentBarChartView = barChartView
            self.ChartView.addSubview(barChartView)
            
            
        }
    }
    
    @IBAction func ShowLineOption(_ sender: UISwitch) {
        if sender.isOn {
            targetLine?.enabled = true
            print("Switch is on")
        } else {
            targetLine?.enabled = false
            print("Switch is off")
        }
    }
    
    //get the lastest 5 buy data to draw the chart
    private func getBuy5Data(completion: @escaping ([Int: (Double,Double,Timestamp)]) -> Void) {
        let db = Firestore.firestore()
        guard let email = Auth.auth().currentUser?.email else {
            print("Error: Current user's email is nil")
            completion([:])
            return
        }
        var BuyRecord: [Int: (Double, Double,Timestamp)] = [:]
        db.collection("OrdersInfo").document(email).getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error)")
                completion([:])
                return
            }
            if let document = document, document.exists {
                var orders = document.data()?["order"] as? [[String: Any]] ?? []
                var countNum = 0
                for order in orders.reversed(){
                    if let stockCode = order["stockCode"] as? String, let shares = order["quantity"] as? Double ,let price = order["price"] as? Double, let status = order["Status"] as? String, let type = order["type"]as? String, let date = order["date"] as? Timestamp, countNum < 5{
                        if status == "Done" && stockCode == self.stockSymbol && type == "buy"{
//                            print("found.")
                            BuyRecord[countNum] = (shares, price, date)
                            countNum += 1
                        }
                    }
                }
                completion(BuyRecord)
            } else {
                print("No document found for user: \(email)")
                completion([:])
            }
        }
    }

    //get the lastest 5 sell data to draw the chart
    private func getSell5Data(completion: @escaping ([Int: (Double,Double,Timestamp)]) -> Void) {
        let db = Firestore.firestore()
        guard let email = Auth.auth().currentUser?.email else {
            print("Error: Current user's email is nil")
            completion([:])
            return
        }
        var SellRecord: [Int: (Double, Double,Timestamp)] = [:]
        db.collection("OrdersInfo").document(email).getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error)")
                completion([:])
                return
            }
            if let document = document, document.exists {
                var orders = document.data()?["order"] as? [[String: Any]] ?? []
                var countNum = 0
                for order in orders.reversed(){
                    if let stockCode = order["stockCode"] as? String, let shares = order["quantity"] as? Double ,let price = order["price"] as? Double, let status = order["Status"] as? String, let type = order["type"]as? String, let date = order["date"] as? Timestamp, countNum < 5{
                        if status == "Done" && stockCode == self.stockSymbol && type == "sell"{
//                            print("found.")
                            SellRecord[countNum] = (shares, price, date)
                            countNum += 1
                        }
                    }
                }
                completion(SellRecord)
            } else {
                print("No document found for user: \(email)")
                completion([:])
            }
        }
    }

    
    
    
    

    
//--------------------------------------------------NAvigation design part------------------------------------------------------------------
    // Navigation part
    
    
//    private func setupCustomBackButton() {
//            let backButton = UIButton(type: .system)
//            let backButtonImage = UIImage(systemName: "house")
//            backButton.setImage(backButtonImage, for: .normal)
//            backButton.tintColor = .white
//            backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
//            let backBarButtonItem = UIBarButtonItem(customView: backButton)
//            navigationItem.leftBarButtonItem = backBarButtonItem
//            print("Custom back button set up")
//        }
//    
//    @objc private func backButtonTapped() {
//            print("Back button tapped")
//            loadTabBarController(atIndex: 0)
//        }
//        
//        private func loadTabBarController(atIndex index: Int) {
//            self.tabBarIndex = index
//            self.performSegue(withIdentifier: "showTabBar", sender: self)
//        }
//
//        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//            if segue.identifier == "showTabBar" {
//                if let tabBarController = segue.destination as? UITabBarController {
//                    tabBarController.selectedIndex = self.tabBarIndex ?? 0
//                }
//            }
//        }
}
