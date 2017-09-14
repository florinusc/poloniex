//
//  CoinPairs.swift
//  poloniex
//
//  Created by Florin Alexandru on 06/04/2017.
//  Copyright © 2017 AppRocket. All rights reserved.
//

import UIKit

struct CoinPair {
    var id = Int()
    var pair = String()
    var firstCurrency = String()
    var secondCurrency = String()
    var name = String()
    var volume = Double()
    var change = Double()
    var lastPrice = Double()
}
