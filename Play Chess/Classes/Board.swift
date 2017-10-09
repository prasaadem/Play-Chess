//
//  Board.swift
//  Play Chess
//
//  Created by Aditya Emani on 10/8/17.
//  Copyright © 2017 Aditya Emani. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

var squarePosition:Dictionary = [String:SCNVector3]()

class Board: SCNNode {
    var boardPlane:SCNPlane = SCNPlane()
    var squares:Array = [Dictionary<String,String>]()
    var movements:Array = [Dictionary<String,Any>]()
    
    override init() {
        super.init()
        
        boardPlane = SCNPlane(width: 1.0, height: 1.0)
        self.geometry = boardPlane
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.clear
        self.geometry?.materials = [material]
        
        self.eulerAngles.x = -.pi / 2
        self.opacity = 1.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func designBoard(planeAnchor:ARPlaneAnchor) -> SCNNode {
        self.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        if let path = Bundle.main.path(forResource: "setSquares", ofType: "plist") {
            if let array = NSArray(contentsOfFile: path){
                squares = array as! Array<Dictionary<String, String>>
                for property in squares{
                    let square = Square(board:self)
                    square.setSquare(properties: property)
                    squarePosition[property["name"]!] = square.position
                }
            }
        }
        return self
    }
}
