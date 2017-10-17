//
//  SKGame.swift
//  Play Chess
//
//  Created by Aditya Emani on 10/16/17.
//  Copyright © 2017 Aditya Emani. All rights reserved.
//

import UIKit
import SceneKit

class SKGame: NSObject {
    var board:SKBoard!
    var vc:SceneViewController!
    var winner: String?
    var turnIsWhite:Bool = true
    
    init(viewController:SceneViewController){
        super.init()
        self.vc = viewController
        self.board = SKBoard(viewController:viewController)
    }
    
    func move(piece chessPieceToMove:SKPiece,sourceIndex:BoardIndex,destIndex:BoardIndex){
        
        let pieceToRemove = board.board[destIndex.row][destIndex.col]
        
        board.remove(piece: pieceToRemove)
        
        board.place(chessPiece:chessPieceToMove, toIndex:destIndex)
        board.board[sourceIndex.row][sourceIndex.col] = SKPiece(index: sourceIndex, board: self.board)
        
    }
    func isMoveValid(piece: SKPiece, fromIndex sourceIndex: BoardIndex, toIndex destIndex: BoardIndex) -> Bool{
        
        guard isTurnColor(sameAsPiece: piece) else{
            return false
        }
        
        return isNormalMoveValid(forPiece: piece, fromIndex: sourceIndex, toIndex: destIndex)
    }
    
    func playerTurn(){
        turnIsWhite = !turnIsWhite
    }
    
    func isTurnColor(sameAsPiece piece:SKPiece) -> Bool {
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
    
    func isNormalMoveValid(forPiece piece:SKPiece, fromIndex source:BoardIndex, toIndex destination:BoardIndex) -> Bool {
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
    
    func isPieceMoveValid(forPiece piece:SKPiece,fromIndex source:BoardIndex,toIndex destination:BoardIndex) -> Bool {
        switch piece.type {
        case .pawn:
            if !piece.doesPawnMoveSeemFine(fromIndex: source, toIndex: destination){
                return false
            }
            if source.col == destination.col{
                if piece.pawnTriesToAdvanceBy2{
                    var moveForward = 0
                    if piece.isWhite{
                        moveForward = 1
                    }
                    else{
                        moveForward = -1
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
    
    func isAttackingAlliedPiece(piece:SKPiece, destinationIndex:BoardIndex) -> Bool {
        
        let destinationPiece:SKPiece = board.board[destinationIndex.row][destinationIndex.col]
        
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
    
    func isOpponentKing(nearKing movingKing: SKPiece, thatGoesTo destinationIndexOfMovingKing: BoardIndex) -> Bool{
        
        //find out which one is the opponent king
        var theOpponentKing: SKPiece
        
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
    
    func isGameOver() -> Bool{
        
        if didSomebodyWin(){
            return true
        }
        return false
    }
    
    func didSomebodyWin() -> Bool{
        if !(board.vc.chessPieces.contains(board.whiteKing)){
            winner = "Black"
            return true
        }
        
        if !(board.vc.chessPieces.contains(board.blackKing)){
            winner = "White"
            return true
        }
        
        return false
    }
    
    func getPlayerChecked() -> String?{
        
        let whiteKingIndex = board.whiteKing.index
        let blackKingIndex = board.blackKing.index
        
        for row in 0..<board.ROWS{
            for col in 0..<board.COLS{
                if board.board[row][col].geometry is SCNSphere{
                    
                }else{
                    let piece = board.board[row][col]
                    
                    if !piece.isWhite{
                        if isNormalMoveValid(forPiece: piece, fromIndex: piece.index, toIndex: whiteKingIndex!){
                            return "White"
                        }
                    }
                    else{
                        if isNormalMoveValid(forPiece: piece, fromIndex: piece.index, toIndex: blackKingIndex!){
                            return "Black"
                        }
                    }
                }
            }
        }
        return nil
    }
    
    func getPawnToBePromoted() -> SKPiece?{
        for piece in board.vc.chessPieces{
            if piece.type == .pawn{
                let pawnIndex = piece.index
                if pawnIndex?.row == 0 || pawnIndex?.row == 7{
                    return piece
                }
            }
        }
        return nil
    }
    
    func makeAIMove(){
        
        //get the white king, if possible
        if getPlayerChecked() == "White"{
            for aChessPiece in board.vc.chessPieces{
                if aChessPiece.geometry is SCNSphere{
                    
                }else{
                    if !aChessPiece.isWhite{
                        
                        guard let source = aChessPiece.index else{
                            continue
                        }
                        
                        guard let dest = board.whiteKing.index else{
                            continue
                        }
                        
                        if isNormalMoveValid(forPiece: aChessPiece, fromIndex: source, toIndex: dest){
                            move(piece: aChessPiece, sourceIndex: source, destIndex: dest)
                            print("AI: ATTACK WHITE KING")
                            return
                        }
                    }
                }
            }
        }
        
        //attack undefended white piece, if there's no check on the black king
        if getPlayerChecked() == nil{
            if didAttackUndefendedPiece(){
                print("AI: ATTACK UNDEFENDED PIECE")
                return
            }
        }
        
        var moveFound = false
        var numberOfTriesToEscapeCheck = 0
        
        searchForMoves: while moveFound == false {
            
            //get rand piece
            let randChessPiecesArrayIndex = Int(arc4random_uniform(UInt32(board.vc.chessPieces.count)))
            let chessPieceToMove = board.vc.chessPieces[randChessPiecesArrayIndex]
            
            guard !chessPieceToMove.isWhite else {
                continue searchForMoves
            }
            
            if chessPieceToMove.geometry is SCNSphere{
                continue searchForMoves
            }
            
            //get rand move
            let movesArray = getArrayOfPossibleMoves(forPiece: chessPieceToMove)
            guard movesArray.isEmpty == false else {
                continue searchForMoves
            }
            
            let randMovesArrayIndex = Int(arc4random_uniform(UInt32(movesArray.count)))
            let randDestIndex = movesArray[randMovesArrayIndex]
            
            guard let sourceIndex = chessPieceToMove.index else {
                continue searchForMoves
            }
            
            //simulate the move on board matrix
            let pieceTaken = board.board[randDestIndex.row][randDestIndex.col]
            board.board[randDestIndex.row][randDestIndex.col] = board.board[sourceIndex.row][sourceIndex.col]
            board.board[sourceIndex.row][sourceIndex.col] = SKPiece(index: sourceIndex, board: self.board)
            
            if numberOfTriesToEscapeCheck < 1000{
                guard getPlayerChecked() != "Black" else {
                    //undo move
                    board.board[sourceIndex.row][sourceIndex.col] = board.board[randDestIndex.row][randDestIndex.col]
                    board.board[randDestIndex.row][randDestIndex.col] = pieceTaken
                    
                    numberOfTriesToEscapeCheck += 1
                    continue searchForMoves
                }
            }
            
            //undo move
            board.board[sourceIndex.row][sourceIndex.col] = board.board[randDestIndex.row][randDestIndex.col]
            board.board[randDestIndex.row][randDestIndex.col] = pieceTaken
            
            //try best move, if any good one
            if didBestMoveForAI(forScoreOver: 2){
                print("AI: BEST MOVE")
                return
            }
            
            if numberOfTriesToEscapeCheck == 0 || numberOfTriesToEscapeCheck == 1000{
                print("AI: SIMPLE RANDOM MOVE")
            }
            else{
                print("AI: RANDOM MOVE TO ESCAPE CHECK")
            }
            
            move(piece: chessPieceToMove, sourceIndex: sourceIndex, destIndex: randDestIndex)
            moveFound = true
        }
    }
    
    func didAttackUndefendedPiece() -> Bool{
        
        loopThatTraversesChessPieces: for attackingChessPiece in board.vc.chessPieces{
            
            guard !attackingChessPiece.isWhite else {
                continue loopThatTraversesChessPieces
            }
            
            guard let source = attackingChessPiece.index else {
                continue loopThatTraversesChessPieces
            }
            
            let possibleDestinations = getArrayOfPossibleMoves(forPiece: attackingChessPiece)
            
            searchForUndefendedWhitePieces: for attackedIndex in possibleDestinations{
                
                let attackedChessPiece = board.board[attackedIndex.row][attackedIndex.col]
                
                if attackedChessPiece.geometry is SCNSphere{
                    continue searchForUndefendedWhitePieces
                }
                
                for row in 0..<board.ROWS{
                    for col in 0..<board.COLS{
                        
                        let defendingChessPiece = board.board[row][col]
                        
                        if attackedChessPiece.geometry is SCNSphere || defendingChessPiece.isWhite{
                            continue searchForUndefendedWhitePieces
                        }
                        
                        let defendingIndex = BoardIndex(row: row, col: col)
                        
                        if isNormalMoveValid(forPiece: defendingChessPiece, fromIndex: defendingIndex, toIndex: attackedIndex, canAttackAllies: true){
                            continue searchForUndefendedWhitePieces
                        }
                    }
                }
                move(piece: attackedChessPiece, sourceIndex: source, destIndex: attackedIndex)
                return true
            }
        }
        return false
    }
    
    func getArrayOfPossibleMoves(forPiece piece: SKPiece) -> [BoardIndex]{
        
        var arrayOfMoves: [BoardIndex] = []
        let source = piece.index
        
        for row in 0..<board.ROWS{
            for col in 0..<board.COLS{
                let dest = BoardIndex(row: row, col: col)
                if isNormalMoveValid(forPiece: piece, fromIndex: source!, toIndex: dest){
                    arrayOfMoves.append(dest)
                }
            }
        }
        return arrayOfMoves
    }
    
    func isNormalMoveValid(forPiece piece: SKPiece, fromIndex source: BoardIndex, toIndex destination: BoardIndex, canAttackAllies: Bool = false) -> Bool{
        
        guard source != destination else {
            print("MOVING PIECE ON ITS CURRENT POSITION")
            return false
        }
        
        if !canAttackAllies{
            guard !isAttackingAlliedPiece(piece: piece, destinationIndex: destination) else {
                print("ATTACKING ALLIED PIECE")
                return false
            }
        }
        
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
    
    func didBestMoveForAI(forScoreOver limit: Int) -> Bool{
        
        guard getPlayerChecked() != "Black" else {
            return false
        }
        
        var bestNetScore = -10
        var bestPiece: SKPiece!
        var bestDest: BoardIndex!
        var bestSource: BoardIndex!
        
        for aChessPiece in board.vc.chessPieces{
            
            guard !aChessPiece.isWhite else {
                continue
            }
            
            guard let source = aChessPiece.index else {
                continue
            }
            
            let actualLocationScore = getScoreForLocation(ofPiece: aChessPiece)
            let possibleDestinations = getArrayOfPossibleMoves(forPiece: aChessPiece)
            
            for dest in possibleDestinations{
                
                var nextLocationScore = 0
                
                //simulate move
                let pieceTaken = board.board[dest.row][dest.col]
                board.board[dest.row][dest.col] = board.board[source.row][source.col]
                board.board[source.row][source.col] = SKPiece(index: source, board: self.board)
                
                nextLocationScore = getScoreForLocation(ofPiece: aChessPiece)
                
                let netScore = nextLocationScore - actualLocationScore
                
                if netScore > bestNetScore{
                    bestNetScore = netScore
                    bestPiece = aChessPiece
                    bestDest = dest
                    bestSource = source
                }
                
                //undo move
                board.board[source.row][source.col] = board.board[dest.row][dest.col]
                board.board[dest.row][dest.col] = pieceTaken
            }
        }
        
        if bestNetScore > limit{
            move(piece: bestPiece, sourceIndex: bestSource, destIndex: bestDest)
            print("AI: BEST NET SCORE: \(bestNetScore)")
            return true
        }
        
        return false
    }
    
    func getScoreForLocation(ofPiece aChessPiece: SKPiece) -> Int{
        
        var locationScore = 0
        
        guard let source = aChessPiece.index else{
            return 0
        }
        
        for row in 0..<board.ROWS{
            for col in 0..<board.COLS{
                if board.board[row][col].geometry is SCNSphere{}else{
                    
                    let dest = BoardIndex(row: row, col: col)
                    
                    if isNormalMoveValid(forPiece: aChessPiece, fromIndex: source, toIndex: dest, canAttackAllies: true){
                        locationScore += 1
                    }
                }
            }
        }
        return locationScore
    }
}
