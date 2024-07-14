//
//  SearchTableViewCell.swift
//  SmartTrade
//
//  Created by Gary She on 2024/7/14.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var symbol: UILabel!
    
    @IBOutlet weak var stockfullname: UILabel!
    

    func configure(with bestMatch: BestMatch) {
        symbol.text = bestMatch.symbol
        stockfullname.text = bestMatch.name
    }
    
    

}
