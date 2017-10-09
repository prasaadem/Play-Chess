//
//  Piece.swift
//  Play Chess
//
//  Created by Aditya Emani on 10/8/17.
//  Copyright © 2017 Aditya Emani. All rights reserved.
//

import UIKit
import SceneKit

enum type {
    case king
    case queen
    case bishop
    case rook
    case knight
    case pawn
}

class Piece: NSObject {
    
    var isWhite:Bool!
    var board:Board!
    var node:SCNNode = SCNNode()
    var player:Player!
    
    init(isWhite:Bool,type:type,board:Board,node:String,name:String) {
        super.init()
        self.isWhite = isWhite
        self.board = board
        self.player = Player(isWhite: isWhite)
        
        let scene = SCNScene(named: "Assets.scnassets/chessPieces.scn")!
        
        switch type {
        case .king:
            self.node = scene.rootNode.childNodes[0]
        case .queen:
            self.node = scene.rootNode.childNodes[1]
        case .bishop:
            self.node = scene.rootNode.childNodes[2]
        case .rook:
            self.node = scene.rootNode.childNodes[3]
        case .knight:
            self.node = scene.rootNode.childNodes[4]
        case .pawn:
            self.node = scene.rootNode.childNodes[5]
        }
        
        self.node.position = squarePosition[node]!
        self.node.name = name
        
        let material = SCNMaterial()
        if self.isWhite{
            material.diffuse.contents = UIColor(red:0.89, green:0.85, blue:0.79, alpha:1.0)
        }else{
            material.diffuse.contents = UIColor(red:0.21, green:0.2, blue:0.2, alpha:1.0)
        }
        self.node.geometry?.materials = [material]
        self.node.scale = SCNVector3Make(0.02, 0.02, 0.02)
        
        self.board.addChildNode(self.node)
        self.player.availablePieces.append(self)
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
