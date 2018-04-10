//
//  BrushPaintView.swift
//  Photo Editor
//
//  Created by cli mini on 2018-04-10.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import Cocoa

class BrushPaintView: CanvasImageView {

    var color: NSColor? = nil
    var brushSize: CGFloat = 0.0
    
    var imageAccumulator: CIImageAccumulator? = nil
    
    
    var brushFilter: CIFilter? = nil
    var compositeFilter: CIFilter? = nil
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        brushSize = 25.0;
        
        color = NSColor(deviceRed: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        brushFilter = CIFilter(name: "CIRadialGradient", withInputParameters: ["inputColor1" : CIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0),
                                                                               "inputRadius0": 0.0])
        compositeFilter = CIFilter(name: "CISourceOverCompositing")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        brushSize = 25.0;
        
        color = NSColor(deviceRed: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        brushFilter = CIFilter(name: "CIRadialGradient", withInputParameters: ["inputColor1" : CIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0),
                                                                               "inputRadius0": 0.0])
        compositeFilter = CIFilter(name: "CISourceOverCompositing")
    }
    
    //////
    
    override func clearView() -> Void {
        self.imageAccumulator = nil
    }
    
    override func viewBoundsDidChange(_ bounds: NSRect) -> Void {
        if self.imageAccumulator != nil && (self.imageAccumulator?.extent.equalTo(bounds))! {
            return
        }
        
        if imageAccumulator == nil && self.getCIImage() != nil {
            imageAccumulator = CIImageAccumulator(extent: bounds, format: kCIFormatRGBA16)!
            imageAccumulator?.setImage(self.getCIImage()!)
        }
        
        /* Create a new accumulator and composite the old one over the it. */
        let newAccumulator: CIImageAccumulator = CIImageAccumulator(extent: bounds, format: kCIFormatRGBA16)!
        var filter: CIFilter = CIFilter(name: "CIConstantColorGenerator", withInputParameters: ["inputColor" : CIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])!
        
        newAccumulator.setImage(filter.outputImage!)
        
        if (self.imageAccumulator != nil)
        {
            filter = CIFilter(name: "CISourceOverCompositing", withInputParameters: ["inputImage" : self.imageAccumulator?.image() as Any,
                                                                                     "inputBackgroundImage": newAccumulator.image()])!
            newAccumulator.setImage(filter.outputImage!)
        }
        
        self.imageAccumulator = newAccumulator;
        
        self.setCIImage((self.imageAccumulator?.image())!)
    }
    
    
    /*  Mouse Action Handlers  */
    override func mouseDragged(with event: NSEvent) {
        let brushFilter = self.brushFilter
        let loc: NSPoint = self.convert(event.locationInWindow, from: nil)
        brushFilter?.setValue(self.brushSize, forKey: "inputRadius1")
        
        let cicolor = CIColor(color: self.color!)
        brushFilter?.setValue(cicolor, forKey: "inputColor0")
        
        let inputCenter: CIVector = CIVector(x: loc.x, y: loc.y)
        brushFilter?.setValue(inputCenter, forKey: "inputCenter")
        
        let compositeFilter = self.compositeFilter
        compositeFilter?.setValue(brushFilter?.outputImage, forKey: "inputImage")
        compositeFilter?.setValue(self.imageAccumulator?.image(), forKey: "inputBackgroundImage")
        
        let brushSize = self.brushSize
        let rect = CGRect(x: loc.x-brushSize, y: loc.y-brushSize, width: 2.0*brushSize, height: 2.0*brushSize)
        self.imageAccumulator?.setImage((compositeFilter?.outputImage)!, dirtyRect: rect)
       
        self.setCIImage((self.imageAccumulator?.image())!, dirtyRect: rect)
    }
    
    override func mouseDown(with event: NSEvent) {
        self.mouseDragged(with: event)
    }
    
}
