//
//  Board.swift
//  Play Chess
//
//  Created by Aditya Emani on 10/8/17.
//  Copyright © 2017 Aditya Emani. All rights reserved.
//

import UIKit
import SceneKit

class Board: SCNPlane {
    override init() {
        super.init()
        self.width = 0.8
        self.height = 0.8
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
