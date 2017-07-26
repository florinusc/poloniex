//
//  Env.swift
//  poloniex
//
//  Created by Florin Alexandru on 30/05/2017.
//  Copyright © 2017 AppRocket. All rights reserved.
//

import Foundation
import SwiftCharts

class Env {
    
    static var iPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}
