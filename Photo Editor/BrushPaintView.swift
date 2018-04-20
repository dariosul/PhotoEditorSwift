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
    var showMask: Bool = true {
        didSet(oldValue){
            if (showMask){
                NSLog("show mask selected")
                self.setCIImage((self.imageAccumulator?.image())!)
            }
            else{
                NSLog("dont show mask")
                self.setCIImage(baseImage!)
                
            }
        }
    }
    
    var baseImage: CIImage? = nil
    
    var imageAccumulator: CIImageAccumulator? = nil
    // added a separate brush accumulator that will duplicate all the brush strokes on the black transparent backgound
    // i tried following based on my understanding of how it should work and it did not work:
    // start an new image accumulator not with the loaded image (photo) but with a black (or white) completely transparent backgound, that way new brushes
    // accumulate / paint the brush trokes over it
    // if showMask is selected then overlay the last accumulated image over the baseImage: use CISourceOverCompositing, withInputParameters: ["inputImage": self.imageAccumulator?.image() as Any,  "inputBackgroundImage": baseImage!]
    var brushMaskAccumulator: CIImageAccumulator? = nil
    var mMouseDragObserver: MouseDragObserver? = nil
    
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
        self.imageAccumulator = nil // paints on screen
        self.brushMaskAccumulator = nil // collect stroke
    }
    
    override func viewBoundsDidChange(_ bounds: NSRect) -> Void {
        if self.imageAccumulator != nil && (self.imageAccumulator?.extent.equalTo(bounds))! {
            return
        }
        
        if imageAccumulator == nil && self.getCIImage() != nil {
            imageAccumulator = CIImageAccumulator(extent: bounds, format: kCIFormatRGBA16)!
            imageAccumulator?.setImage(self.getCIImage()!)
            baseImage = self.getCIImage()
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
        
        setupBrushMaskAccumulator(bounds)
        
        self.setCIImage((self.imageAccumulator?.image())!)
    }
    
    func setupBrushMaskAccumulator(_ bounds: NSRect) ->Void {
        if brushMaskAccumulator == nil {
            brushMaskAccumulator = CIImageAccumulator(extent: bounds, format: kCIFormatRGBA16)!
        }
        let newAccumulator: CIImageAccumulator = CIImageAccumulator(extent: bounds, format: kCIFormatRGBA16)!
        var filter: CIFilter = CIFilter(name: "CIConstantColorGenerator", withInputParameters: ["inputColor" : CIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)])!
        newAccumulator.setImage(filter.outputImage!)
        
        if (self.brushMaskAccumulator != nil)
        {
            filter = CIFilter(name: "CISourceOverCompositing", withInputParameters: ["inputImage" : self.brushMaskAccumulator?.image() as Any,
                                                                                    "inputBackgroundImage": newAccumulator.image()])!
            newAccumulator.setImage(filter.outputImage!)
        }
        self.brushMaskAccumulator = newAccumulator
    }
    
    /*  Mouse Action Handlers  */
    override func mouseDragged(with event: NSEvent) {
        
        // Get new brushed point
        let loc: NSPoint = self.convert(event.locationInWindow, from: nil)
        
        // Add point to current selected brush
        let brushFilter = self.brushFilter
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
        
        /////////////
        /// update the brush mask too
        let brushMaskFilter = CIFilter(name: "CIRadialGradient",
                                       withInputParameters: ["inputColor0": CIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0),
                                                            "inputColor1" : CIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0),
                                                            "inputRadius0": 0.0, "inputRadius1": self.brushSize,
                                                            "inputCenter": inputCenter])
        
        let compositeMaskFilter = CIFilter(name: "CISourceOverCompositing")
        compositeMaskFilter?.setValue(brushMaskFilter?.outputImage, forKey: "inputImage")
        compositeMaskFilter?.setValue(self.brushMaskAccumulator?.image(), forKey: "inputBackgroundImage")

        self.brushMaskAccumulator?.setImage((compositeMaskFilter?.outputImage)!, dirtyRect: rect)
        /////////////////
        
        if (showMask){
            self.setCIImage((self.imageAccumulator?.image())!, dirtyRect: rect)
        }
        
        // pass updated mask to filters
        mMouseDragObserver!.onNewBrushStroke(self.brushMaskAccumulator?.image())
    }
    
    override func mouseDown(with event: NSEvent) {
        self.mouseDragged(with: event)
    }
    
}

protocol MouseDragObserver{
    func onNewBrushStroke(_ ciMaskImage: CIImage?) -> Void
}
