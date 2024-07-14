//
//  DateValueFormatter.swift
//  SmartTrade
//
//  Created by Gary She on 2024/6/27.
//

import DGCharts
import Charts
import Foundation

class DateValueFormatter: AxisValueFormatter {
    private let dateFormatter: DateFormatter
    
    init(dateFormatter: DateFormatter) {
        self.dateFormatter = dateFormatter
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date(timeIntervalSince1970: value)
        return dateFormatter.string(from: date)
    }
}
