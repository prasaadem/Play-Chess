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
    
    var vc:ViewController!
    var whiteKing:Piece!
    var blackKing:Piece!
    var board:[[Piece]]!
    
    let ROWS = 8
    let COLS = 8
    
    init(viewController:ViewController) {
        super.init()
        
        self.vc = viewController
        
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
        self.addPieces()
        return self
    }
    
    func addPieces(){
        let oneRow = Array(repeating: Piece(), count: COLS)
        board = Array(repeating: oneRow, count: ROWS)
        
        for row in 0..<ROWS{
            for col in 0..<COLS{
                let boardIndex = BoardIndex(row: row, col: col)
                switch row {
                case 0:
                    switch col {
                    case 0:
                        board[row][col] = Piece(isWhite: false, type: .rook, board: self, index:boardIndex ,name:"rook\(row)\(col)")
                    case 1:
                        board[row][col] = Piece(isWhite: false, type: .knight, board: self, index:boardIndex ,name:"rook\(row)\(col)")
                    case 2:
                        board[row][col] = Piece(isWhite: false, type: .bishop, board: self, index:boardIndex ,name:"rook\(row)\(col)")
                    case 3:
                        board[row][col] = Piece(isWhite: false, type: .queen, board: self, index:boardIndex ,name:"rook\(row)\(col)")
                    case 4:
                        blackKing = Piece(isWhite: false, type: .king, board: self, index:boardIndex ,name:"rook\(row)\(col)")
                        board[row][col] = blackKing
                    case 5:
                        board[row][col] = Piece(isWhite: false, type: .bishop, board: self, index:boardIndex,name:"rook\(row)\(col)")
                    case 6:
                        board[row][col] = Piece(isWhite: false, type: .knight, board: self, index:boardIndex,name:"rook\(row)\(col)")
                    case 7:
                        board[row][col] = Piece(isWhite: false, type: .rook, board: self, index:boardIndex,name:"rook\(row)\(col)")
                    default:
                        print("default")
                    }
                case 1:
                    board[row][col] = Piece(isWhite: false, type: .pawn, board: self, index:boardIndex,name:"rook\(row)\(col)")
                case 6:
                    board[row][col] = Piece(isWhite: true, type: .pawn, board: self, index:boardIndex,name:"rook\(row)\(col)")
                case 7:
                    switch col {
                    case 0:
                        board[row][col] = Piece(isWhite: true, type: .rook, board: self, index:boardIndex,name:"rook\(row)\(col)")
                    case 1:
                        board[row][col] = Piece(isWhite: true, type: .knight, board: self, index:boardIndex,name:"rook\(row)\(col)")
                    case 2:
                        board[row][col] = Piece(isWhite: true, type: .bishop, board: self, index:boardIndex,name:"rook\(row)\(col)")
                    case 3:
                        board[row][col] = Piece(isWhite: true, type: .queen, board: self, index:boardIndex,name:"rook\(row)\(col)")
                    case 4:
                        whiteKing = Piece(isWhite: true, type: .king, board: self, index:boardIndex,name:"rook\(row)\(col)")
                        board[row][col] = whiteKing
                    case 5:
                        board[row][col] = Piece(isWhite: true, type: .bishop, board: self, index:boardIndex,name:"rook\(row)\(col)")
                    case 6:
                        board[row][col] = Piece(isWhite: true, type: .knight, board: self, index:boardIndex,name:"rook\(row)\(col)")
                    case 7:
                        board[row][col] = Piece(isWhite: true, type: .rook, board: self, index:boardIndex,name:"rook\(row)\(col)")
                    default:
                        print("default")
                    }
                    
                default:
                    board[row][col] = Piece(index: boardIndex, board: self)
                }
            }
        }
    }
    
    func place(chessPiece:Piece, toIndex destIndex:BoardIndex){
        let boardIndex = "\(destIndex.row)\(destIndex.col)"
        let destPosition = squarePosition[boardIndex]!
        let action1 = SCNAction.move(to:destPosition , duration: 0.1)
        chessPiece.runAction(action1, completionHandler: {
            self.movements.append(self.vc.movement)
            self.vc.isPieceSelected = false
            chessPiece.index = destIndex
            self.board[destIndex.row][destIndex.col] = chessPiece
        })
    }
    
    func remove(piece:SCNNode){
        if piece is Piece {
            let pieceToRemove:Piece = (piece as? Piece)!
            let index = pieceToRemove.index
            board[(index?.row)!][(index?.col)!] = Piece(index: index!, board: self)
            
            if let indexInChessPieceArray = vc.chessPieces.index(of: pieceToRemove){
                vc.chessPieces.remove(at: indexInChessPieceArray)
            }
            piece.removeFromParentNode()
        }
    }
}
