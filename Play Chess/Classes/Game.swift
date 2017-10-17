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
    var vc:ViewController!
    
    let whitePlayer = Player(isWhite: true)
    let blackPlayer = Player(isWhite: false)
    
    var turnIsWhite:Bool = true
    
    init(viewController:ViewController){
        super.init()
        self.vc = viewController
        self.board = Board(viewController:viewController)
    }
    
    func move(piece chessPieceToMove:Piece,sourceIndex:BoardIndex,destIndex:BoardIndex){
        
        let pieceToRemove = board.board[destIndex.row][destIndex.col]
        
        board.remove(piece: pieceToRemove)

        board.place(chessPiece:chessPieceToMove, toIndex:destIndex)
        board.board[sourceIndex.row][sourceIndex.col] = Piece(index: sourceIndex, board: self.board)
        
    }
    func isMoveValid(piece: Piece, fromIndex sourceIndex: BoardIndex, toIndex destIndex: BoardIndex) -> Bool{
        
        guard isTurnColor(sameAsPiece: piece) else{
            return false
        }
        
        return isNormalMoveValid(forPiece: piece, fromIndex: sourceIndex, toIndex: destIndex)
    }
    
    func playerTurn(){
        turnIsWhite = !turnIsWhite
    }
    
    func isTurnColor(sameAsPiece piece:Piece) -> Bool {
        if piece.isWhite{
            if turnIsWhite{
                return true
            }
        }else{
            if !turnIsWhite{
                return true
            }
        }
        return false
    }
    
    func isNormalMoveValid(forPiece piece:Piece, fromIndex source:BoardIndex, toIndex destination:BoardIndex) -> Bool {
        guard source != destination else{
            return false
        }
        
        guard !(isAttackingAlliedPiece(piece: piece, destinationIndex: destination)) else{
            print("Attacking allied piece")
            return false
        }
        
        guard isPieceMoveValid(forPiece: piece, fromIndex: source, toIndex: destination) else {
            return false
        }
        
        return true
    }
    
    func isPieceMoveValid(forPiece piece:Piece,fromIndex source:BoardIndex,toIndex destination:BoardIndex) -> Bool {
                switch piece.type {
                case .pawn:
                    if !piece.doesPawnMoveSeemFine(fromIndex: source, toIndex: destination){
                        return false
                    }
                    if source.col == destination.col{
                        if piece.pawnTriesToAdvanceBy2{
                            var moveForward = 0
                            if piece.isWhite{
                                moveForward = -1
                            }
                            else{
                                moveForward = 1
                            }
                            if board.board[destination.row][destination.col].geometry is SCNSphere && board.board[destination.row - moveForward][destination.col].geometry is SCNSphere{
                                return true
                            }
                        }
                        else{
                            if board.board[destination.row][destination.col].geometry is SCNSphere{
                                return true
                            }
                        }
                    }
                    else{
                        if !(board.board[destination.row][destination.col].geometry is SCNSphere){
                            return true
                        }
                    }
                    return false
                case .rook:
                    if !piece.doesRookMoveSeemFine(fromIndex: source, toIndex: destination){
                        return false
                    }
                    return checkForObstaclePieces(source: source, destination: destination)
                case .bishop:
                    if !(piece.doesBishopMoveSeemFine(fromIndex: source, toIndex: destination)){
                        return false
                    }
                    return checkForObstaclePieces(source: source, destination: destination)
                case .queen:
                    if !piece.doesQueenMoveSeemFine(fromIndex: source, toIndex: destination){
                        return false
                    }
                    return checkForObstaclePieces(source: source, destination: destination)
                case .knight:
                    return piece.doesKnightMoveSeemFine(fromIndex: source, toIndex: destination)
                case .king:
                    if !piece.doesKingMoveSeemFine(fromIndex: source, toIndex: destination){
                        return false
                    }
                    if isOpponentKing(nearKing: piece, thatGoesTo: destination){
                        return false
                    }
                case .dot:
                    return false
                case .none:
                    return false
                case .some(_):
                    return false
                }
        return true
    }
    
    func isAttackingAlliedPiece(piece:Piece, destinationIndex:BoardIndex) -> Bool {
        
        let destinationPiece:Piece = board.board[destinationIndex.row][destinationIndex.col]
        
        guard !(destinationPiece.geometry is SCNSphere) else {
            return false
        }
        
        return (piece.isWhite == destinationPiece.isWhite)
    }
    
    func checkForObstaclePieces(source:BoardIndex,destination:BoardIndex) -> Bool{
        
        var increaseRow = 0
        
        if destination.row - source.row != 0{
            increaseRow = (destination.row - source.row) / abs(destination.row - source.row)
        }
        
        var increaseCol = 0
        
        if destination.col - source.col != 0{
            increaseCol = (destination.col - source.col) / abs(destination.col - source.col)
        }
        
        var nextRow = source.row + increaseRow
        var nextCol = source.col + increaseCol
        
        while nextRow != destination.row || nextCol != destination.col{
            if !(board.board[nextRow][nextCol].geometry is SCNSphere){
                return false
            }
            
            nextRow += increaseRow
            nextCol += increaseCol
        }
        
        return true
    }
    
    func isOpponentKing(nearKing movingKing: Piece, thatGoesTo destinationIndexOfMovingKing: BoardIndex) -> Bool{
        
        //find out which one is the opponent king
        var theOpponentKing: Piece
        
        if movingKing == board.whiteKing{
            theOpponentKing = board.blackKing
        }
        else{
            theOpponentKing = board.whiteKing
        }
        
        //get index of opponent king
        let indexOfOpponentKing: BoardIndex = theOpponentKing.index
        
        //compute absolute difference between kings
        let differenceInRows = abs(indexOfOpponentKing.row - destinationIndexOfMovingKing.row)
        let differenceInCols = abs(indexOfOpponentKing.col - destinationIndexOfMovingKing.col)
        
        //if they're too close, move is invalid
        if case 0...1 = differenceInRows{
            if case 0...1 = differenceInCols{
                return true
            }
        }
        return false
    }
}

