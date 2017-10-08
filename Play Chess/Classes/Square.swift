//
//  Square.swift
//  Play Chess
//
//  Created by Aditya Emani on 10/8/17.
//  Copyright © 2017 Aditya Emani. All rights reserved.
//

import UIKit
import SceneKit

class Square: SCNBox {
    var value :(Int,Int)!
    var board:Board!
    
    init(board:Board) {
        super.init()
        self.board = board
        
        self.width = board.width/8
        self.height = board.width/8
        self.length = board.width/8
        
        self.position = board.position
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
