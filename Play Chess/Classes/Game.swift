//
//  Game.swift
//  Play Chess
//
//  Created by Aditya Emani on 10/8/17.
//  Copyright © 2017 Aditya Emani. All rights reserved.
//

import UIKit

class Game: NSObject {
    var board:Board!
    
    let whitePlayer = Player(isWhite: true)
    let blackPlayer = Player(isWhite: false)
    
    var turnIsWhite:Bool = true
    
    override init() {
        super.init()
        board = Board()
    }
}
