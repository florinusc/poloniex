//
//  PriceLineCell.swift
//  poloniex
//
//  Created by Florin Uscatu on 8/24/17.
//  Copyright © 2017 AppRocket. All rights reserved.
//

import UIKit

class PriceLineCell: UITableViewCell {

    
    @IBOutlet weak var currentPriceLabel: UILabel!
    @IBOutlet weak var priceLineView: PriceLineView!
    @IBOutlet weak var priceChangeLabel: UILabel!
    @IBOutlet weak var lowestPriceLabel: UILabel!
    @IBOutlet weak var highestPriceLabel: UILabel!
    @IBOutlet weak var firstVolumeLabel: UILabel!
    @IBOutlet weak var secondVolumeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
