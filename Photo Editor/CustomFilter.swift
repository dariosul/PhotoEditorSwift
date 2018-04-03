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

public class CIFilterWithMask: CIFilter {
    var inputCusomFilterParams: Dictionary<String, AnyObject>? = nil
    var brushStrokes: Array<BrushStroke> = Array<BrushStroke>()
    var maskImage: CIImage? = nil // can have public access to request just the mask
    //internal var mFilter: CIFilter? = nil //filter object of a certain type but no mask applied
    //var inputImage: CIImage? = nil
    
    override public var outputImage: CIImage? {
        get{
            return super.outputImage
        }                // run filter recipie with new mask
    }
    
    init?(name filterName: String){
        super.init()
        name = filterName
        setDefaults()
        //mFilter = CIFilter(name: filterName)
        //super.init(name: filterName) /// this needs to be a disignated initialiser
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    var lastBrushPoints: BrushStroke = BrushStroke() { // turn this into optional
        didSet{
            if lastBrushPoints != oldValue {
                // updateMask
            }
        }
    }

}

