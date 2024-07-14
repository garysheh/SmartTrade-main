//
//  PriceMarkerView.swift
//  SmartTrade
//
//  Created by Gary She on 2024/6/27.
//

import UIKit
import DGCharts

class PriceMarkerView: MarkerView {
    private var label: UILabel!
        private let circleRadius: CGFloat = 6.0
        private let circleColor = UIColor.systemGreen
        private let circleBorderColor = UIColor.white
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupView()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupView()
        }
        
        private func setupView() {
            label = UILabel()
            label.textColor = .white
            label.font = .boldSystemFont(ofSize: 12)
            label.textAlignment = .center
            label.backgroundColor = .white
            addSubview(label)
        }
        
        override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
            label.text = String(format: "%.2f", entry.y)
            layoutIfNeeded()
        }
        
        override func draw(context: CGContext, point: CGPoint) {
            super.draw(context: context, point: point)

            // Draw the circle
            let circleRect = CGRect(x: point.x - circleRadius, y: point.y - circleRadius, width: circleRadius * 2, height: circleRadius * 2)
            
            context.setFillColor(circleColor.cgColor)
            context.fillEllipse(in: circleRect)
            
            context.setStrokeColor(circleBorderColor.cgColor)
            context.setLineWidth(2.0)
            context.strokeEllipse(in: circleRect)
            
            // Draw the label above the circle
            let labelSize = label.intrinsicContentSize
            let labelX = point.x - labelSize.width / 2
            let labelY = point.y - circleRadius - labelSize.height
            
            label.frame = CGRect(x: labelX, y: labelY, width: labelSize.width, height: labelSize.height)
            label.drawText(in: label.frame)
        }
        
        override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
            // Offset the marker so it draws above the point
            return CGPoint(x: -label.bounds.size.width / 2, y: -label.bounds.size.height - circleRadius * 2)
        }
}
