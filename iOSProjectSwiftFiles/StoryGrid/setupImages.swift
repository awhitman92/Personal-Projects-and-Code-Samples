//
//  setupImages.swift
//  StoryGrid
//
//  Created by Andrew Whitman on 2015-10-02.
//  Copyright © 2015 awhitman92. All rights reserved.
//

import Foundation
import Photos

func getRowColNumbers(numberofImages: Int) -> (square: Int, long: Int, short: Int){
    let squarenum = floor(sqrt(Double(numberofImages)))
    let square = Int(squarenum)
    var length: Int
    var width: Int
    var imagesLost: Int
    var imagesUsed: Int
    
    length = numberofImages/2
    width = numberofImages/length
    
    var valuesFound: Bool = false
    
    while(!valuesFound){
        if(length > width*2){
            width = width+1
            length = numberofImages/width
            width = numberofImages/length
        }
        else{
            valuesFound = true
        }
    }
    imagesUsed = length*width
    imagesLost = numberofImages-imagesUsed
    print(numberofImages/3)
    print(imagesLost)
    let short = width
    let long = length
    
    return (square, long, short)
}




