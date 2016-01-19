//
//  arrayShuffle.swift
//  StoryGrid
//
//  Created by Andrew Whitman on 2015-10-02.
//  Copyright © 2015 awhitman92. All rights reserved.
//

import Foundation


extension Array
{
    /** Randomizes the order of an array's elements. */
    mutating func shuffle()
    {
        for _ in 0..<10
        {
            sortInPlace { (_,_) in arc4random() < arc4random() }
        }
    }
}

