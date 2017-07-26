//
//  ChartCell.swift
//  poloniex
//
//  Created by Florin Alexandru on 29/05/2017.
//  Copyright © 2017 AppRocket. All rights reserved.
//

import UIKit

class ChartCell: UITableViewCell {
    
    var graph: GraphView?
    
    override func awakeFromNib() {
        
        graph = GraphView(frame: CGRect(x: 2.5, y: 2.5, width: (self.bounds.width - 5), height: (self.bounds.height - 5)))
        
        graph?.graphPoints = [25, 34, 12, 54, 12, 42]
        
        self.addSubview(graph!)
        
    }
    
}
