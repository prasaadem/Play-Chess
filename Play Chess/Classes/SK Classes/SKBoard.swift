//
//  SKBoard.swift
//  Play Chess
//
//  Created by Aditya Emani on 10/16/17.
//  Copyright © 2017 Aditya Emani. All rights reserved.
//

import UIKit
import SceneKit

class SKBoard: SCNNode {
    var squarePosition:Dictionary = [String:SCNVector3]()
        var boardPlane:SCNPlane = SCNPlane()
        var squares:Array = [Dictionary<String,String>]()
        var movements:Array = [Dictionary<String,Any>]()
        
        var vc:SceneViewController!
        var whiteKing:SKPiece!
        var blackKing:SKPiece!
        var board:[[SKPiece]]!
        
        let ROWS = 8
        let COLS = 8
        
        init(viewController:SceneViewController) {
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
        
        func designBoard(planeAnchor:SCNVector3) -> SCNNode {
            self.position = planeAnchor
            if let path = Bundle.main.path(forResource: "setSquares", ofType: "plist") {
                if let array = NSArray(contentsOfFile: path){
                    squares = array as! Array<Dictionary<String, String>>
                    for property in squares{
                        let square = SKSquare(board:self)
                        square.setSquare(properties: property)
                        squarePosition[property["name"]!] = square.position
                    }
                }
            }
//            self.addPieces()
            return self
        }
        
        func addPieces(){
            let oneRow = Array(repeating: SKPiece(), count: COLS)
            board = Array(repeating: oneRow, count: ROWS)
            
            for row in 0..<ROWS{
                for col in 0..<COLS{
                    let boardIndex = BoardIndex(row: row, col: col)
                    switch row {
                    case 0:
                        switch col {
                        case 0:
                            board[row][col] = SKPiece(isWhite: true, type: .rook, board: self, index:boardIndex ,name:"rook\(row)\(col)")
                        case 1:
                            board[row][col] = SKPiece(isWhite: true, type: .knight, board: self, index:boardIndex ,name:"knight\(row)\(col)")
                        case 2:
                            board[row][col] = SKPiece(isWhite: true, type: .bishop, board: self, index:boardIndex ,name:"bishop\(row)\(col)")
                        case 3:
                            board[row][col] = SKPiece(isWhite: true, type: .queen, board: self, index:boardIndex ,name:"queen\(row)\(col)")
                        case 4:
                            blackKing = SKPiece(isWhite: true, type: .king, board: self, index:boardIndex ,name:"king\(row)\(col)")
                            board[row][col] = blackKing
                        case 5:
                            board[row][col] = SKPiece(isWhite: true, type: .bishop, board: self, index:boardIndex,name:"bishop\(row)\(col)")
                        case 6:
                            board[row][col] = SKPiece(isWhite: true, type: .knight, board: self, index:boardIndex,name:"knight\(row)\(col)")
                        case 7:
                            board[row][col] = SKPiece(isWhite: true, type: .rook, board: self, index:boardIndex,name:"rook\(row)\(col)")
                        default:
                            print("default")
                        }
                    case 1:
                        board[row][col] = SKPiece(isWhite: true, type: .pawn, board: self, index:boardIndex,name:"pawn\(row)\(col)")
                    case 6:
                        board[row][col] = SKPiece(isWhite: false, type: .pawn, board: self, index:boardIndex,name:"pawn\(row)\(col)")
                    case 7:
                        switch col {
                        case 0:
                            board[row][col] = SKPiece(isWhite: false, type: .rook, board: self, index:boardIndex,name:"rook\(row)\(col)")
                        case 1:
                            board[row][col] = SKPiece(isWhite: false, type: .knight, board: self, index:boardIndex,name:"knight\(row)\(col)")
                        case 2:
                            board[row][col] = SKPiece(isWhite: false, type: .bishop, board: self, index:boardIndex,name:"bishop\(row)\(col)")
                        case 3:
                            board[row][col] = SKPiece(isWhite: false, type: .queen, board: self, index:boardIndex,name:"queen\(row)\(col)")
                        case 4:
                            whiteKing = SKPiece(isWhite: false, type: .king, board: self, index:boardIndex,name:"king\(row)\(col)")
                            board[row][col] = whiteKing
                        case 5:
                            board[row][col] = SKPiece(isWhite: false, type: .bishop, board: self, index:boardIndex,name:"bishop\(row)\(col)")
                        case 6:
                            board[row][col] = SKPiece(isWhite: false, type: .knight, board: self, index:boardIndex,name:"knight\(row)\(col)")
                        case 7:
                            board[row][col] = SKPiece(isWhite: false, type: .rook, board: self, index:boardIndex,name:"rook\(row)\(col)")
                        default:
                            print("default")
                        }
                        
                    default:
                        board[row][col] = SKPiece(index: boardIndex, board: self)
                    }
                    self.vc.chessPieces.append(board[row][col])
                }
            }
        }
        
        func place(chessPiece:SKPiece, toIndex destIndex:BoardIndex){
            let boardIndex = "\(destIndex.row)\(destIndex.col)"
            let destPosition = squarePosition[boardIndex]!
            let action1 = SCNAction.move(to:destPosition , duration: 0.1)
            
            self.movements.append(self.vc.movement)
            self.vc.isPieceSelected = false
            chessPiece.index = destIndex
            self.board[destIndex.row][destIndex.col] = chessPiece
            chessPiece.runAction(action1, completionHandler: nil)
        }
        
        func remove(piece:SCNNode){
            if piece is Piece {
                let pieceToRemove:SKPiece = (piece as? SKPiece)!
                let index = pieceToRemove.index
                board[(index?.row)!][(index?.col)!] = SKPiece(index: index!, board: self)
                
                if let indexInChessPieceArray = vc.chessPieces.index(of: pieceToRemove){
                    vc.chessPieces.remove(at: indexInChessPieceArray)
                }
                piece.removeFromParentNode()
            }
        }
}
