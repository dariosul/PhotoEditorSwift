//
//  CustomFilter.swift
//  Photo Editor
//
//  Created by Darya Ismailova on 2018-04-02.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import Foundation
import CoreImage


struct BrushParams{
    var NibWidth: Float = 0.0
    var Feathering: Float = 0.0
}

extension BrushParams{
    static func != (left: BrushParams, right: BrushParams)-> Bool {
        return !(left == right)
    }
    
    static func == (left: BrushParams, right: BrushParams) -> Bool {
        return  (left.NibWidth == right.NibWidth) && (left.Feathering == right.Feathering)
    }
}

struct BrushStroke{
    var params: BrushParams = BrushParams()
    var points: Array<CGPoint> = Array<CGPoint>()
}

extension BrushStroke{
    static func != (left: BrushStroke, right: BrushStroke)-> Bool {
        return !(left == right)
    }
    
    static func == (left: BrushStroke, right: BrushStroke) -> Bool {
        return  (left.params == right.params) && (left.points == right.points)
    }
}

class CIFilterWithMask: CIFilter {
    var filterParams: Dictionary<String, AnyObject>? = nil
    var brushStrokes: Array<BrushStroke> = Array<BrushStroke>()
    var maskImage: CIImage? = nil
    
    var lastBrushPoints: BrushStroke = BrushStroke() { // turn this into optional
        didSet{
            if lastBrushPoints != oldValue {
                // updateMask
                // run filter recipie with new mask

            }
        }
    }
    func init(name: String)->CIFilterWithMask?{
    return CIFilter(name: name)
    }
//    override var outputImage: CIImage! {
//        
//    }
}
