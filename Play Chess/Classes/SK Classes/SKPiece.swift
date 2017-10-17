//
//  SKPiece.swift
//  Play Chess
//
//  Created by Aditya Emani on 10/16/17.
//  Copyright © 2017 Aditya Emani. All rights reserved.
//

import UIKit
import SceneKit

class SKPiece: SCNNode {
    var isWhite:Bool = true
    var board:SKBoard!
    var player:Player!
    var isSelected:Bool = false
    var index:BoardIndex!
    var type:type!
    
    //pawn
    var pawnTriesToAdvanceBy2: Bool = false
    
    init(isWhite:Bool,type:type,board:SKBoard,index:BoardIndex,name:String) {
        super.init()
        self.isWhite = isWhite
        self.board = board
        self.player = Player(isWhite: isWhite)
        
        let scene = SCNScene(named: "Assets.scnassets/chessPieces.scn")!
        
        switch type {
        case .king:
            self.geometry = scene.rootNode.childNodes[0].geometry
        case .queen:
            self.geometry = scene.rootNode.childNodes[1].geometry
        case .bishop:
            self.geometry = scene.rootNode.childNodes[2].geometry
        case .rook:
            self.geometry = scene.rootNode.childNodes[3].geometry
        case .knight:
            self.geometry = scene.rootNode.childNodes[4].geometry
        case .pawn:
            self.geometry = scene.rootNode.childNodes[5].geometry
        case .dot:
            print("dot")
        }
        
        self.index = index
        let boardIndex = "\(index.row)\(index.col)"
        self.position = squarePosition[boardIndex]!
        self.name = name
        self.type = type
        
        //        self.index = BoardIndex(row: (node[0] as Int), col: (node[1] as Int))
        
        let material = SCNMaterial()
        if self.isWhite{
            material.diffuse.contents = UIColor(red:0.89, green:0.85, blue:0.79, alpha:1.0)
        }else{
            material.diffuse.contents = UIColor(red:0.21, green:0.2, blue:0.2, alpha:1.0)
        }
        self.geometry?.materials = [material]
        self.scale = SCNVector3Make(0.02, 0.02, 0.02)
        
        self.board.addChildNode(self)
    }
    
    init(index:BoardIndex,board:SKBoard) {
        super.init()
        
        self.board = board
        self.player = Player(isWhite: self.isWhite)
        
        let sphere = SCNSphere(radius: 0.1)
        self.geometry = sphere
        let boardIndex = "\(index.row)\(index.col)"
        self.position = squarePosition[boardIndex]!
        self.index = index
        self.type = .dot
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red:0.89, green:0.85, blue:0.79, alpha:1.0)
        self.geometry?.materials = [material]
        self.scale = SCNVector3Make(0.02, 0.02, 0.02)
        
        self.board.addChildNode(self)
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    func doesKingMoveSeemFine(fromIndex source:BoardIndex, toIndex destination:BoardIndex) -> Bool {
        let differenceInRows = abs(destination.row - source.row)
        let differenceInCols = abs(destination.col - source.col)
        
        if case 0...1 = differenceInRows{
            if case 0...1 = differenceInCols{
                return true
            }
        }
        return false
    }
    
    func doesQueenMoveSeemFine(fromIndex source:BoardIndex, toIndex destination:BoardIndex) -> Bool {
        if source.row == destination.row || source.col == destination.col{
            return true
        }
        if abs(destination.row - source.row) == abs(destination.col - source.col){
            return true
        }
        return false
    }
    
    func doesBishopMoveSeemFine(fromIndex source:BoardIndex, toIndex destination:BoardIndex) -> Bool {
        if abs(destination.row - source.row) == abs(destination.col - source.col){
            return true
        }
        return false
    }
    
    func doesKnightMoveSeemFine(fromIndex source:BoardIndex, toIndex destination:BoardIndex) -> Bool {
        let validMoves = [(source.row - 1, source.col + 2), (source.row - 2, source.col + 1), (source.row - 2, source.col - 1), (source.row - 1, source.col - 2), (source.row + 1, source.col - 2), (source.row + 2, source.col - 1), (source.row + 2, source.col + 1), (source.row + 1, source.col + 2)]
        
        for (validRow, validCol) in validMoves{
            if destination.row == validRow && destination.col == validCol{
                return true
            }
        }
        
        return false
    }
    
    func doesRookMoveSeemFine(fromIndex source:BoardIndex, toIndex destination:BoardIndex) -> Bool {
        if source.row == destination.row || source.col == destination.col{
            return true
        }
        return false
    }
    
    func doesPawnMoveSeemFine(fromIndex source:BoardIndex, toIndex destination:BoardIndex) -> Bool {
        //check advance by 2
        if source.col == destination.col{
            if (source.row == 1 && destination.row == 3 && self.isWhite == true) || (source.row == 6 && destination.row == 4 && self.isWhite == false){
                pawnTriesToAdvanceBy2 = true
                return true
            }
        }
        
        pawnTriesToAdvanceBy2 = false
        
        //check advance by 1
        var moveForward = 0
        
        if self.isWhite{
            moveForward = 1
        }
        else{
            moveForward = -1
        }
        
        if destination.row == source.row + moveForward{
            if (destination.col == source.col - 1) || (destination.col == source.col) || (destination.col == source.col + 1){
                return true
            }
        }
        
        return false
    }
}
