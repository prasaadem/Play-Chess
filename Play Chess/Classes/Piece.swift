//
//  Piece.swift
//  Play Chess
//
//  Created by Aditya Emani on 10/8/17.
//  Copyright © 2017 Aditya Emani. All rights reserved.
//

import UIKit
import SceneKit

class Piece: SCNNode {
    var isWhite:Bool!
    
    init(isWhite:Bool) {
        super.init()
        self.isWhite = isWhite
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//    
//    func name() -> String {
//        preconditionFailure("This method must be overridden")
//    }
//    
//    func canMove(end:(Int, Int), endPiece:Piece? = nil, registeredMove:Bool = true) -> Bool {
//        preconditionFailure("This method must be overridden")
//    }
//    
//    func didMove() {
//        preconditionFailure("This method must be overridden")
//    }
//    
//    //Used during checkmate detection
//    func getMovementPath(_ end:(Int, Int)) -> [Square]? {
//        preconditionFailure("This method must be overridden")
//    }
}
