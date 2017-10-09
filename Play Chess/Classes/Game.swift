//
//  Game.swift
//  Play Chess
//
//  Created by Aditya Emani on 10/8/17.
//  Copyright © 2017 Aditya Emani. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class Game: NSObject {
    var board:Board!
    
    let whitePlayer = Player(isWhite: true)
    let blackPlayer = Player(isWhite: false)
    
    var turnIsWhite:Bool = true
    
    override init(){
        super.init()
        self.board = Board()
    }
    
    func addPieces(){
        let array:Array = [0,1,6,7]
        for i in 0...7{
            for j in array{
                if j == 1{
                    _ = Piece(isWhite: true, type: .pawn, board: self.board, node: "1\(i)",name:"pawn1\(i)")
                }
                if j == 6{
                    _ = Piece(isWhite: false, type: .pawn, board: self.board, node: "6\(i)",name:"pawn6\(i)")
                }
                if j == 0{
                    switch i{
                    case 0:
                        _ = Piece(isWhite: true, type: .rook, board: self.board, node: "\(j)\(i)",name:"rook\(j)\(i)")
                    case 1:
                        _ = Piece(isWhite: true, type: .knight, board: self.board, node: "\(j)\(i)",name:"knight\(j)\(i)")
                    case 2:
                        _ = Piece(isWhite: true, type: .bishop, board: self.board, node: "\(j)\(i)",name:"bishop\(j)\(i)")
                    case 3:
                        _ = Piece(isWhite: true, type: .king, board: self.board, node: "\(j)\(i)",name:"king\(j)\(i)")
                    case 4:
                        _ = Piece(isWhite: true, type: .queen, board: self.board, node: "\(j)\(i)",name:"queen\(j)\(i)")
                    case 5:
                        _ = Piece(isWhite: true, type: .bishop, board: self.board, node: "\(j)\(i)",name:"bishop\(j)\(i)")
                    case 6:
                        _ = Piece(isWhite: true, type: .knight, board: self.board, node: "\(j)\(i)",name:"knight\(j)\(i)")
                    case 7:
                        _ = Piece(isWhite: true, type: .rook, board: self.board, node: "\(j)\(i)",name:"rook\(j)\(i)")
                    default:
                        print("default")
                    }
                }
                if j == 7{
                    switch i{
                    case 0:
                        _ = Piece(isWhite: false, type: .rook, board: self.board, node: "\(j)\(i)",name:"rook\(j)\(i)")
                    case 1:
                        _ = Piece(isWhite: false, type: .knight, board: self.board, node: "\(j)\(i)",name:"knight\(j)\(i)")
                    case 2:
                        _ = Piece(isWhite: false, type: .bishop, board: self.board, node: "\(j)\(i)",name:"bishop\(j)\(i)")
                    case 3:
                        _ = Piece(isWhite: false, type: .king, board: self.board, node: "\(j)\(i)",name:"king\(j)\(i)")
                    case 4:
                        _ = Piece(isWhite: false, type: .queen, board: self.board, node: "\(j)\(i)",name:"queen\(j)\(i)")
                    case 5:
                        _ = Piece(isWhite: false, type: .bishop, board: self.board, node: "\(j)\(i)",name:"bishop\(j)\(i)")
                    case 6:
                        _ = Piece(isWhite: false, type: .knight, board: self.board, node: "\(j)\(i)",name:"knight\(j)\(i)")
                    case 7:
                        _ = Piece(isWhite: false, type: .rook, board: self.board, node: "\(j)\(i)",name:"rook\(j)\(i)")
                    default:
                        print("default")
                    }
                }
            }
            
        }
    }
}

