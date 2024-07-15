//
//  SpreadViewController.swift
//  SmartTrade
//
//  Created by Gary She on 2024/7/1
//

import UIKit
import Charts
import DGCharts

class SpreadViewController: UIViewController {
    
    var lineChartView: LineChartView!
    let tradePairs = ["BIO-ETSY", "FTNT-JBHT", "AWK-PODD", "IVZ-MHK", "LH-LYV"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the chart view
        lineChartView = LineChartView()
        lineChartView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(lineChartView)
        
        // Set up Auto Layout constraints
        NSLayoutConstraint.activate([
            lineChartView.topAnchor.constraint(equalTo: self.view.topAnchor),
            lineChartView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            lineChartView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            lineChartView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        // Load and parse the CSV file
        if let filePath = Bundle.main.path(forResource: "spread", ofType: "csv") {
                    do {
                        let csvData = try String(contentsOfFile: filePath, encoding: .utf8)
                        let csvLines = csvData.components(separatedBy: "\n").filter { !$0.isEmpty }
                        let selectedTradePair = tradePairs.randomElement()!
                        // Parse the CSV data
                        var dates = [String]()
                        var values = [Double]()
                        if let headerLine = csvLines.first {
                            let headers = headerLine.components(separatedBy: ",")
                            if let selectedPairIndex = headers.firstIndex(of: selectedTradePair) {
                                for line in csvLines.dropFirst() {
                                    let columns = line.components(separatedBy: ",")
                                    if columns.count > selectedPairIndex, let value = Double(columns[selectedPairIndex]) {
                                        dates.append(columns[0]) // Assuming the first column is the date
                                        values.append(value)
                                    }
                                }
                                setChart(dates: dates, values: values, tradePair: selectedTradePair)
                            } else {
                                print("\(selectedTradePair) column not found")
                            }
                        }
                        
                    } catch {
                        print("Error reading CSV file: \(error)")
                    }
                }
            }
    
    func setChart(dates: [String], values: [Double], tradePair: String) {
            var dataEntries: [ChartDataEntry] = []
            
            for i in 0..<dates.count {
                let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
                dataEntries.append(dataEntry)
            }
            
            let lineChartDataSet = LineChartDataSet(entries: dataEntries, label: tradePair)
            lineChartDataSet.colors = [NSUIColor.cyan]
            lineChartDataSet.circleColors = [NSUIColor.cyan]
            lineChartDataSet.circleRadius = 4.0
            lineChartDataSet.drawValuesEnabled = true
            
            lineChartDataSet.valueTextColor = .white
            lineChartDataSet.valueFont = .systemFont(ofSize: 12)
            
            let lineChartData = LineChartData(dataSet: lineChartDataSet)
            
            lineChartView.data = lineChartData
            lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dates)
            lineChartView.xAxis.labelPosition = .bottom
            lineChartView.xAxis.granularity = 1
            lineChartView.xAxis.labelRotationAngle = -45
            lineChartView.xAxis.avoidFirstLastClippingEnabled = true
            lineChartView.xAxis.forceLabelsEnabled = true
            lineChartView.xAxis.setLabelCount(dates.count / 5, force: true) // Adjust the label count as needed
            lineChartView.xAxis.labelTextColor = .white
            lineChartView.leftAxis.labelTextColor = .white
            lineChartView.rightAxis.labelTextColor = .white
            lineChartView.legend.textColor = .white
            lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInOutQuart)
            lineChartView.setVisibleXRangeMaximum(10) // Adjust the range as needed
            lineChartView.moveViewToX(0)
        
        /*
        // Add limit lines
        let upperLimit = ChartLimitLine(limit: 1.0, label: "")
            upperLimit.lineColor = .red
        let lowerLimit = ChartLimitLine(limit: -1.0, label: "")
            lowerLimit.lineColor = .red
        let zeroLine = ChartLimitLine(limit: 0.0, label: "")
            zeroLine.lineColor = .blue
        let upperGreenLimit = ChartLimitLine(limit: 0.5, label: "")
            upperGreenLimit.lineColor = .green
        let lowerGreenLimit = ChartLimitLine(limit: -0.5, label: "")
            lowerGreenLimit.lineColor = .green

        lineChartView.leftAxis.addLimitLine(upperLimit)
        lineChartView.leftAxis.addLimitLine(lowerLimit)
        lineChartView.leftAxis.addLimitLine(zeroLine)
        lineChartView.leftAxis.addLimitLine(upperGreenLimit)
        lineChartView.leftAxis.addLimitLine(lowerGreenLimit)
         */
    }
}
