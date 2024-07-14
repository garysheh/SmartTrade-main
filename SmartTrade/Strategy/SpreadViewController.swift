//
//  SpreadViewController.swift
//  SmartTrade
//
//  Created by Gary She on 2024/7/12.
//

import UIKit
import Charts
import DGCharts

class SpreadViewController: UIViewController {

    var lineChartView: LineChartView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        lineChartView = LineChartView()
        lineChartView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(lineChartView)
        NSLayoutConstraint.activate([
            lineChartView.topAnchor.constraint(equalTo: self.view.topAnchor),
            lineChartView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            lineChartView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            lineChartView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        if let filePath = Bundle.main.path(forResource: "spread", ofType: "csv") {
            do {
                let csvData = try String(contentsOfFile: filePath, encoding: .utf8)
                let csvLines = csvData.components(separatedBy: "\n").filter { !$0.isEmpty }
                
                // Parse the CSV data
                var dates = [String]()
                var values = [Double]()
                if let headerLine = csvLines.first {
                    let headers = headerLine.components(separatedBy: ",")
                    if let awkPoddIndex = headers.firstIndex(of: "AWK-PODD") {
                        for line in csvLines.dropFirst() {
                            let columns = line.components(separatedBy: ",")
                            if columns.count > awkPoddIndex, let value = Double(columns[awkPoddIndex]) {
                                dates.append(columns[0])
                                values.append(value)
                            }
                        }
                        setChart(dates: dates, values: values)
                    } else {
                        print("AWK-PODD column not found")
                    }
                }
                
            } catch {
                print("Error reading CSV file: \(error)")
            }
        }
    }
    
    func setChart(dates: [String], values: [Double]) {
        var dataEntries: [ChartDataEntry] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for i in 0..<dates.count {
            if let date = dateFormatter.date(from: dates[i]) {
                let timeInterval = date.timeIntervalSince1970
                let dataEntry = ChartDataEntry(x: timeInterval, y: values[i])
                dataEntries.append(dataEntry)
            }
        }
        
        lineChartView.xAxis.labelTextColor = .white
        lineChartView.leftAxis.labelTextColor = .white
        lineChartView.rightAxis.labelTextColor = .white
        lineChartView.legend.textColor = .white
        let lineChartDataSet = LineChartDataSet(entries: dataEntries, label: "spread")
        lineChartDataSet.valueTextColor = .white  // Set the color of value labels to black
        lineChartDataSet.drawCirclesEnabled = false
        lineChartDataSet.mode = .cubicBezier
        lineChartDataSet.lineWidth = 1.5
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        lineChartView.data = lineChartData
        lineChartView.xAxis.valueFormatter = YearValueFormatter()
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.granularity = 365 * 24 * 60 * 60
        lineChartView.xAxis.labelCount = 10
        lineChartView.xAxis.avoidFirstLastClippingEnabled = false
        lineChartView.xAxis.drawGridLinesEnabled = false
        if let minDate = dateFormatter.date(from: "2015-12-31")?.timeIntervalSince1970,
           let maxDate = dateFormatter.date(from: "2024-12-31")?.timeIntervalSince1970 {
            lineChartView.xAxis.axisMinimum = minDate
            lineChartView.xAxis.axisMaximum = maxDate
        }

        // Add limit lines
        let upperLimit = ChartLimitLine(limit: 1.0, label: "")
        upperLimit.lineColor = .red
        let lowerLimit = ChartLimitLine(limit: -1.0, label: "")
        lowerLimit.lineColor = .red
        let zeroLine = ChartLimitLine(limit: 0.0, label: "")
        zeroLine.lineColor = .black
        let upperGreenLimit = ChartLimitLine(limit: 0.5, label: "")
        upperGreenLimit.lineColor = .green
        let lowerGreenLimit = ChartLimitLine(limit: -0.5, label: "")
        lowerGreenLimit.lineColor = .green

        lineChartView.leftAxis.addLimitLine(upperLimit)
        lineChartView.leftAxis.addLimitLine(lowerLimit)
        lineChartView.leftAxis.addLimitLine(zeroLine)
        lineChartView.leftAxis.addLimitLine(upperGreenLimit)
        lineChartView.leftAxis.addLimitLine(lowerGreenLimit)

        lineChartView.leftAxis.drawLimitLinesBehindDataEnabled = true
        lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInOutQuart)
        lineChartView.setVisibleXRangeMaximum(10 * 365 * 24 * 60 * 60)
        lineChartView.moveViewToX(dataEntries.first?.x ?? 0)
    }
}

class YearValueFormatter: NSObject, AxisValueFormatter {
    private let dateFormatter: DateFormatter
    
    override init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date(timeIntervalSince1970: value)
        return dateFormatter.string(from: date)
    }
}
