//
//  SKSquare.swift
//  Play Chess
//
//  Created by Aditya Emani on 10/16/17.
//  Copyright © 2017 Aditya Emani. All rights reserved.
//

import UIKit
import SceneKit

class SKSquare: SCNNode {
    var index :BoardIndex!
    var board:SKBoard!
    
    init(board:SKBoard) {
        super.init()
        self.board = board
        let squareBox = SCNBox(width: 0.1, height: 0.1, length: 0.001, chamferRadius: 0)
        self.geometry = squareBox
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSquare(properties:Dictionary<String, String>){
        
        self.position = SCNVector3Make((properties["xPosition"]! as NSString).floatValue,(properties["yPosition"]! as NSString).floatValue, (properties["zPosition"]! as NSString).floatValue)
        
        self.index = BoardIndex(row: (properties["value1"]! as NSString).integerValue, col: (properties["value2"]! as NSString).integerValue)
        
        let material = SCNMaterial()
        if (properties["color"] == "white"){
            material.diffuse.contents = UIColor(white:0.56, alpha:0.8)
        }else{
            material.diffuse.contents = UIColor(red:0.25, green:0.25, blue:0.28, alpha:0.8)
        }
        self.geometry?.materials = [material]
        
        self.board.addChildNode(self)
    }
}
