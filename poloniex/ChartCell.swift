//
//  ChartCell.swift
//  poloniex
//
//  Created by Florin Alexandru on 29/05/2017.
//  Copyright © 2017 AppRocket. All rights reserved.
//

import UIKit

class ChartCell: UITableViewCell {
    
    //var graph: GraphView?
    public var graphPoints: Array<Double> = []
    
    override func awakeFromNib() {
//        graph = GraphView(frame: CGRect(x: 2.5, y: 2.5, width: (self.bounds.width - 5), height: (self.bounds.height - 5)))
//        graph?.graphPoints = graphPoints
//        self.addSubview(graph!)
    }
}
