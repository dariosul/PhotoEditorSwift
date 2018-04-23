//
//  DevelopSettings.swift
//  Photo Editor
//
//  Created by Darya Ismailova on 2018-04-23.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import Foundation

class DevelopSettings{
    
    var globalSettings: NSDictionary = NSDictionary() // ["exposure_value" : float_val, ...]
    
    var brush1Settings: NSDictionary = NSDictionary() // ["filter settings" : ["exposure_value" : float_val, ...],
                                                        // "brush_mask": CIImage? = mMaskImage ]
}
