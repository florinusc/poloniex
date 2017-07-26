//
//  GraphView.swift
//  poloniex
//
//  Created by Florin Uscatu on 7/23/17.
//  Copyright © 2017 AppRocket. All rights reserved.
//

import UIKit

@IBDesignable class GraphView: UIView {
    
    @IBInspectable var startColor = UIColor.white.cgColor
    @IBInspectable var endColor = UIColor.gray.cgColor
    
    var descriptionLabel = UILabel()
    
    var averageValueLabel = UILabel()
    
    var graphPoints:[Double] = [] {
        didSet {
            drawGraph()
        }
    }
    
    let graphBackground = CAShapeLayer()
    let graphGridLineLayer = CAShapeLayer()
    let graphPointsLayer = CAShapeLayer()
    let graphLineLayer = CAShapeLayer()
    let whiteHaze = CALayer()
    let gl = CAGradientLayer()
    
    var maxValue: Double {
        get {
            if graphPoints.max()! > 40.0 {
                let currentMax = ceil(graphPoints.max()! / 100.0)
                print("current max is: \(currentMax * 100.0)")
                return currentMax * 100.0
            } else {
                let currentMax = ceil(graphPoints.max()! / 10.0)
                print("current max is: \(currentMax * 10.0)")
                return currentMax * 10.0
            }
        }
    }
    
    var valueLabels: Array<Double> {
        get {
            var tempArray = [Double]()
            if maxValue > 40.0 {
                let numberOfLines = Int(maxValue/100.0)
                for i in 0...numberOfLines {
                    tempArray.append(Double(i)*100.0)
                }
            } else {
                let numberOfLines = Int(maxValue/10.0)
                for i in 0...numberOfLines {
                    tempArray.append(Double(i)*10.0)
                }
            }
            return tempArray
        }
    }
    
    override func setNeedsDisplay() {
        draw(bounds)
    }
    
    func drawGraph() {
        backgroundColor = UIColor.clear
        
        gl.frame = bounds
        gl.colors = [startColor, endColor]
        gl.locations = [0.0, 1.0]
        
        layer.addSublayer(gl)
        
        let frame = UIBezierPath(roundedRect: bounds, cornerRadius: 8.0)
        
        graphBackground.path = frame.cgPath
        
        graphBackground.strokeColor = UIColor.clear.cgColor
        graphBackground.fillColor = UIColor.black.cgColor
        
        layer.mask = graphBackground
        
        whiteHaze.frame = bounds
        whiteHaze.backgroundColor = UIColor(white: 1.0, alpha: 0.3).cgColor
        
        layer.addSublayer(whiteHaze)
        
        layer.mask = graphBackground
        
        if graphPoints.count > 3 {
            
            let yPadding = CGFloat(40)
            let xPadding = CGFloat(20)
            
            descriptionLabel.frame = CGRect(x: xPadding, y: CGFloat(5), width: CGFloat(100), height: CGFloat(15))
            descriptionLabel.font = UIFont(name: "Helvetica", size: 12)
            descriptionLabel.textColor = UIColor.black
            self.addSubview(descriptionLabel)
            
            let averageValue:Double = (graphPoints as NSArray).value(forKeyPath: "@avg.self") as! Double
            if graphPoints.max()! > 40.0 {
                averageValueLabel.text = "Average value: \(Int(averageValue)) mg/dl"
            } else {
                averageValueLabel.text = "Average value: \(averageValue) mmol/l"
            }
            averageValueLabel.frame = CGRect(x: xPadding, y: CGFloat(20), width: CGFloat(200), height: CGFloat(15))
            averageValueLabel.font = UIFont(name: "Helvetica", size: 12)
            averageValueLabel.textColor = UIColor.black
            self.addSubview(averageValueLabel)
            
            let gridLinePath = UIBezierPath()
            
            let ySegments = (frame.bounds.height - yPadding) / CGFloat(maxValue)
            
            for (i, value) in valueLabels.enumerated() {
                
                let yPosition = ySegments * (CGFloat(maxValue) - CGFloat(value)) + yPadding
                
                if i != 0 {
                    let valueLabel = UILabel(frame: CGRect(x: frame.bounds.width - CGFloat(17), y: yPosition - 10, width: 15, height: 20))
                    valueLabel.font = UIFont(name: "Helvetica", size: 8)
                    valueLabel.text = "\(Int(value))"
                    valueLabel.textColor = UIColor.black
                    self.addSubview(valueLabel)
                    
                    gridLinePath.move(to: CGPoint(x: xPadding, y: yPosition))
                    gridLinePath.addLine(to: CGPoint(x: frame.bounds.width-xPadding, y: yPosition))
                }
                
            }
            
            for (i, _) in graphPoints.enumerated() {
                let xPosition = ((frame.bounds.width - 2*xPadding)/CGFloat(graphPoints.count - 1)) * CGFloat(i) + xPadding - 5
                let countingLabel = UILabel(frame: CGRect(x: xPosition, y: frame.bounds.height - 20, width: 10, height: 20))
                countingLabel.text = "\(i + 1)"
                countingLabel.textAlignment = .center
                countingLabel.font = UIFont(name: "Helvetica", size: 8)
                countingLabel.textColor = UIColor.black
                self.addSubview(countingLabel)
            }
            
            graphGridLineLayer.path = gridLinePath.cgPath
            graphGridLineLayer.fillColor = UIColor.clear.cgColor
            graphGridLineLayer.strokeColor = UIColor(white: 0, alpha: 0.5).cgColor
            
            layer.addSublayer(graphGridLineLayer)
            
            let graphLine = UIBezierPath()
            
            let ySegmentsPoints = (frame.bounds.height - yPadding) / CGFloat(maxValue)
            let yPositionPoints = ySegmentsPoints * CGFloat(maxValue - graphPoints[0]) + yPadding
            
            let pointsPath = UIBezierPath()
            
            pointsPath.addArc(withCenter: CGPoint(x: xPadding, y: yPositionPoints),
                              radius: CGFloat(2), startAngle: CGFloat(0), endAngle: CGFloat(90), clockwise: true)
            
            graphLine.move(to: CGPoint(x: xPadding,
                                       y: yPositionPoints ))
            
            for point in 1...(graphPoints.count - 1) {
                let yPositionPoint = ySegmentsPoints * CGFloat(maxValue - graphPoints[point]) + yPadding
                graphLine.addLine(to: CGPoint(x: ((frame.bounds.width - 2*xPadding)/CGFloat(graphPoints.count - 1))*CGFloat(point)+xPadding,
                                              y: yPositionPoint ))
                pointsPath.move(to: CGPoint(x: ((frame.bounds.width - 2*xPadding)/CGFloat(graphPoints.count - 1))*CGFloat(point)+xPadding, y: yPositionPoint))
                pointsPath.addArc(withCenter: CGPoint(x: ((frame.bounds.width - 2*xPadding)/CGFloat(graphPoints.count - 1))*CGFloat(point)+xPadding, y: yPositionPoint),
                                  radius: CGFloat(2), startAngle: CGFloat(0), endAngle: CGFloat(90), clockwise: true)
                print("point: \(graphPoints[point]) was graphed")
            }
            
            graphLineLayer.path = graphLine.cgPath
            graphLineLayer.fillColor = UIColor.clear.cgColor
            graphLineLayer.strokeColor = UIColor.black.cgColor
            
            layer.addSublayer(graphLineLayer)
            
            graphPointsLayer.path = pointsPath.cgPath
            graphPointsLayer.fillColor = UIColor.black.cgColor
            graphPointsLayer.strokeColor = UIColor.black.cgColor
            
            layer.addSublayer(graphPointsLayer)
            
        } else {
            
            print("showing error label")
            
            let errorLabel = UILabel()
            
            errorLabel.frame = CGRect(x: self.bounds.width/2 - 125, y: self.bounds.height/2 - 10 , width: 250, height: 20)
            errorLabel.font = UIFont(name: "Helvetica", size: 12)
            errorLabel.text = "There are not enough entries to draw a graph"
            errorLabel.textColor = UIColor.black
            errorLabel.isHidden = false
            errorLabel.textAlignment = .center
            
            self.addSubview(errorLabel)
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        drawGraph()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        drawGraph()
    }
    
}
