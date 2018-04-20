/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 PhotoSplitViewController allows us to easily access the child controllers as specific types.
*/

import Cocoa

class PhotoSplitViewController: NSSplitViewController {
    
    // This method is less generic than our protocol-based approach, but sometimes necessary. 
    // Here we assume that at least one child must conform to the desired type; the use of an implicitly-unwrapped optional results in a runtime error if this isn't true.
    
    var sidebarController: SidebarViewController! {
        return childViewControllers.lazy.filter { $0 is SidebarViewController }.first as? SidebarViewController
    }
    
    var developSplitViewController: DevelopSplitViewController! {
        return childViewControllers.lazy.filter { $0 is DevelopSplitViewController }.first as? DevelopSplitViewController
    }
    
    var canvasController: CanvasViewController! {
        return childViewControllers.lazy.filter { $0 is CanvasViewController }.first as? CanvasViewController
    }
    
    func setBrushSize(_ size: Float) -> Void {
        let test = self.canvasController
        test?.canvasImageView.brushSize = CGFloat(size)
    }
    
    func setBrushColor(_ color: NSColor) -> Void {
        canvasController.canvasImageView.color = color
    }
    
    func setShowMask(_ showMask: Bool) -> Void {
        canvasController.canvasImageView.showMask = showMask
    }
    func setDisplayImage(_ ciImage: CIImage) -> Void {
        canvasController.canvasImageView.setCIImage(ciImage)
    }
}
