//
//  Player.swift
//  Play Chess
//
//  Created by Aditya Emani on 10/8/17.
//  Copyright © 2017 Aditya Emani. All rights reserved.
//

import UIKit

class Player: NSObject {
    var isWhite:Bool!
    var availablePieces = [Piece]()
    var capturedPieces  = [Piece]()
//    var kingPiece:King!
    
    init (isWhite:Bool) {
        self.isWhite = isWhite
    }
}
