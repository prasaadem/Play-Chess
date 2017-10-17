//
//  BoardIndex.swift
//  Play Chess
//
//  Created by Aditya Emani on 10/9/17.
//  Copyright © 2017 Aditya Emani. All rights reserved.
//

struct BoardIndex: Equatable {
    
    var row: Int
    var col: Int
    
    init(row: Int, col: Int) {
        self.row = row
        self.col = col
    }
    
    static func ==(lhs: BoardIndex, rhs: BoardIndex) -> Bool{
        return (lhs.row == rhs.row && lhs.col == rhs.col)
    }
}
