//
//  FlashingCircleView.swift
//  SmartTrade
//
//  Created by Gary She on 2024/6/27.
//

import UIKit
import DGCharts

class FlashingCircleView: MarkerView {

    private var timer: Timer?
        private let circleLayer = CAShapeLayer()
        private let priceLabel = UILabel()

        override init(frame: CGRect) {
            super.init(frame: frame)
            setupView()
            startFlashing()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setupView() {
            // Set the frame for the circle layer
            let circleDiameter: CGFloat = 20
            let circleFrame = CGRect(x: bounds.width - circleDiameter, y: (bounds.height - circleDiameter) / 2, width: circleDiameter, height: circleDiameter)
            circleLayer.path = UIBezierPath(ovalIn: circleFrame).cgPath
            circleLayer.fillColor = UIColor.systemGreen.cgColor
            circleLayer.borderColor = UIColor.white.cgColor
            circleLayer.borderWidth = 2.0
            layer.addSublayer(circleLayer)

            // Set the frame for the price label
            let labelWidth: CGFloat = 70
            let labelHeight: CGFloat = 30
            priceLabel.font = UIFont.boldSystemFont(ofSize: 12)
            priceLabel.textColor = .black
            priceLabel.backgroundColor = .white
            priceLabel.layer.cornerRadius = 10
            priceLabel.layer.masksToBounds = true
            priceLabel.textAlignment = .center
            priceLabel.frame = CGRect(x: bounds.width - circleDiameter - labelWidth - 8, y: (bounds.height - labelHeight) / 2, width: labelWidth, height: labelHeight)
            addSubview(priceLabel)
        }

        func updatePrice(_ price: Double) {
            priceLabel.text = String(format: "%.2f", price)
        }

        func startFlashing() {
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(flash), userInfo: nil, repeats: true)
        }

        func stopFlashing() {
            timer?.invalidate()
            timer = nil
            circleLayer.opacity = 1.0
        }

        func resumeFlashing() {
            startFlashing()
        }

        @objc private func flash() {
            circleLayer.opacity = circleLayer.opacity == 1.0 ? 0.0 : 1.0
        }
    }
