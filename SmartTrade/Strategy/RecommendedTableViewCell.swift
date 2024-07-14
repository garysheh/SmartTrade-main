//
//  RecommendedTableViewCell.swift
//  SmartTrade
//
//  Created by Gary She on 2024/6/26.
//

import UIKit
import DGCharts
import Charts
import Combine

class RecommendedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var stockTitleLabel: UILabel!
    @IBOutlet weak var stockPriceLabel: UILabel!
    @IBOutlet weak var chartView: UIView!
    
    private let lineChartView: LineChartView = {
            let chartView = LineChartView()
            chartView.translatesAutoresizingMaskIntoConstraints = false
            return chartView
        }()
    
    private var flashingCircleView: FlashingCircleView?
    private var cancellable: AnyCancellable? = nil
    private let apiService = APIService()
    private var cancellables = Set<AnyCancellable>()
        
    override func awakeFromNib() {
        super.awakeFromNib()
        setupChart()
    }
    
    private func setupChart() {
        chartView.addSubview(lineChartView)
            
            NSLayoutConstraint.activate([
                lineChartView.leadingAnchor.constraint(equalTo: chartView.leadingAnchor),
                lineChartView.trailingAnchor.constraint(equalTo: chartView.trailingAnchor),
                lineChartView.topAnchor.constraint(equalTo: chartView.topAnchor),
                lineChartView.bottomAnchor.constraint(equalTo: chartView.bottomAnchor)
            ])
            
            lineChartView.rightAxis.enabled = false
            lineChartView.leftAxis.enabled = false
            lineChartView.xAxis.enabled = false
            lineChartView.legend.enabled = false
            lineChartView.chartDescription.enabled = false
            lineChartView.setScaleEnabled(false)
            lineChartView.drawGridBackgroundEnabled = false
            
            
            // Add the marker view
            let marker = PriceMarkerView(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
            marker.chartView = lineChartView
            lineChartView.marker = marker
        }
        
        private func setupRoundedCorners() {
            self.contentView.layer.cornerRadius = 15
            self.contentView.layer.masksToBounds = true
            
            stockTitleLabel.layer.cornerRadius = 10
            stockTitleLabel.layer.masksToBounds = true
            
            stockPriceLabel.layer.cornerRadius = 10
            stockPriceLabel.layer.masksToBounds = true
        }
        
        func configure(with searchResult: SearchResult) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            
            if let price = Double(searchResult.price) {
                let formattedPrice = formatter.string(from: NSNumber(value: price)) ?? searchResult.price
                DispatchQueue.main.async {
                    self.stockTitleLabel.text = searchResult.symbol
                    self.stockPriceLabel.text = formattedPrice
                    let percentString = searchResult.percent.replacingOccurrences(of: "%", with: "")
                    if let percent = Double(percentString) {
                        self.stockPriceLabel.backgroundColor =  UIColor(red: 27/255, green: 187/255, blue: 125/255, alpha: 1.0)
                        self.stockPriceLabel.layer.cornerRadius = 15
                        self.stockPriceLabel.layer.masksToBounds = true
                        self.stockPriceLabel.textColor = UIColor.white
                    } else {
                        self.stockPriceLabel.text = "N/A"
                        self.stockPriceLabel.textColor = UIColor.white
                    }
                }
            }
            fetchHourlyPriceData(for: searchResult.symbol)
        }
    
    private func fetchHourlyPriceData(for symbol: String) {
        cancellable = apiService.fetchHourlyPricesPublisher(symbol: symbol)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching hourly prices: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] prices in
                DispatchQueue.main.async {
                    self?.updateChart(with: prices)
                }
            })
    }
    
    private func updateChart(with prices: [Double]) {
        var entries: [ChartDataEntry] = []
            for (index, price) in prices.enumerated() {
                let entry = ChartDataEntry(x: Double(index), y: price)
                entries.append(entry)
            }

            // Create the main dataset without circles
            let dataSet = LineChartDataSet(entries: entries, label: "")
            dataSet.colors = [NSUIColor.systemGreen]
            dataSet.lineWidth = 2.0
            dataSet.drawCirclesEnabled = false
            dataSet.mode = .cubicBezier
            dataSet.drawHorizontalHighlightIndicatorEnabled = false
            dataSet.drawVerticalHighlightIndicatorEnabled = false

            // Add shadow
            dataSet.drawFilledEnabled = true
            dataSet.fillAlpha = 1.0

            // Create a gradient fill
            let gradientColors = [NSUIColor.systemGreen.withAlphaComponent(0.3).cgColor, NSUIColor.clear.cgColor] as CFArray
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: [0.0, 1.0])
            dataSet.fill = LinearGradientFill(gradient: gradient!, angle: 90.0)

            let data = LineChartData(dataSet: dataSet)
            data.setDrawValues(false)
            lineChartView.data = data
            lineChartView.notifyDataSetChanged()

            // Add the flashing circle view
            if let lastEntry = entries.last {
                let circleSize: CGFloat = 24.0  // Circle size
                
                // Convert the data point to the view's coordinates
                       let point = lineChartView.getTransformer(forAxis: .left).pixelForValues(x: lastEntry.x, y: lastEntry.y)
                       let circleFrame = CGRect(
                           x: point.x - circleSize / 2,
                           y: point.y - circleSize / 2,
                           width: circleSize,
                           height: circleSize
                       )

                       if flashingCircleView == nil {
                           flashingCircleView = FlashingCircleView(frame: circleFrame)
                           lineChartView.addSubview(flashingCircleView!)
                       } else {
                           flashingCircleView?.frame = circleFrame
                       }
                       flashingCircleView?.updatePrice(lastEntry.y)
                   }

                   // Add gesture recognizers for dragging
                   let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
                   lineChartView.addGestureRecognizer(panGesture)
               }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: lineChartView)
        
        switch gesture.state {
        case .began:
            flashingCircleView?.stopFlashing()
        case .changed:
            updateFlashingCirclePosition(at: location)
        case .ended, .cancelled, .failed:
            flashingCircleView?.resumeFlashing()
        default:
            break
        }
    }

    private func updateFlashingCirclePosition(at location: CGPoint) {
        guard let data = lineChartView.data else { return }
        
        let highlight = lineChartView.getHighlightByTouchPoint(location)
        if let highlight = highlight, let dataSet = lineChartView.data?.dataSets[highlight.dataSetIndex] {
            if let entry = dataSet.entryForIndex(Int(highlight.x)) {
                let circleSize: CGFloat = 20.0
                let point = lineChartView.getTransformer(forAxis: .left).pixelForValues(x: entry.x, y: entry.y)
                let circleFrame = CGRect(
                    x: point.x - circleSize / 2,
                    y: point.y - circleSize / 2,
                    width: circleSize,
                    height: circleSize
                )
                
                flashingCircleView?.frame = circleFrame
                flashingCircleView?.updatePrice(entry.y)
            }
        }
    }
}
