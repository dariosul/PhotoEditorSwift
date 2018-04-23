//
//  DevelopBaseBrush.swift
//  Photo Editor
//
//  Created by cli mini on 2018-04-19.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import Cocoa

class DevelopBaseBrush {
    /* For brush stroke collection
     */
    var strokeAccumulator: CIImageAccumulator? = nil
    
    /* For brush stroke updating
     */
    var compositeFilter: CIFilter? = nil
    
    /* For adding point to brush stroke
     */
    var strokePointFilter: CIFilter? = CIFilter(name: "CIRadialGradient",
                                                withInputParameters: ["inputColor1" : CIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0),
                                                                      "inputRadius0": 0.0, "inputRadius1": 0.0])
    
    // Clear stroke
    var isClearStroke = false
    
    // invert stroke
    var isInvertStroke = false
    
    //var developSettings: NSDictionary = NSDictionary()
    
    
}
