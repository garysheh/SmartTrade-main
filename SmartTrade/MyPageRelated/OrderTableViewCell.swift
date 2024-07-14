//
//  OrderTableViewCell.swift
//  SmartTrade
//
//  Created by Frank Leung on 9/7/2024.
//

import UIKit

class OrderTableViewCell: UITableViewCell {

    @IBOutlet weak var stockSymbol: UILabel!
    @IBOutlet weak var orderDate: UILabel!
    @IBOutlet weak var stockPrice: UILabel!
    @IBOutlet weak var orderType: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        guard let imageView = imageView else { return }
//            
//        // 将 imageView 移到最底层
//        contentView.sendSubviewToBack(imageView)
        
        contentView.bringSubviewToFront(stockSymbol)
        contentView.bringSubviewToFront(orderDate)
        contentView.bringSubviewToFront(stockPrice)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
