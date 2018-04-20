//
//  DevelopSplitViewController.swift
//  Photo Editor
//
//  Created by cli mini on 2018-04-09.
//  Copyright © 2018 Apple Inc. All rights reserved.
//
import Cocoa

class DevelopSplitViewController: NSSplitViewController {
    
    // This method is less generic than our protocol-based approach, but sometimes necessary.
    // Here we assume that at least one child must conform to the desired type; the use of an implicitly-unwrapped optional results in a runtime error if this isn't true.
    
    var editToolViewController: BrushToolViewController! {
        return childViewControllers.lazy.filter { $0 is BrushToolViewController }.first as? BrushToolViewController
    }
    
//    var globalToolViewController: NSViewController! {
//        return childViewControllers.lazy.filter { $0 is NSViewController }.first as? NSViewController
//    }
    
    func setBrushSize(_ size: Float) -> Void {
        let parentCtl: PhotoSplitViewController = self.parent as! PhotoSplitViewController
        parentCtl.setBrushSize(size)
    }
    
    func setBrushColor(_ color: NSColor) -> Void {
        let parentCtl: PhotoSplitViewController = self.parent as! PhotoSplitViewController
        parentCtl.setBrushColor(color)
    }

    func setShowMask(_ showMask: Bool) -> Void {
        let parentCtl: PhotoSplitViewController = self.parent as! PhotoSplitViewController
        parentCtl.setShowMask(showMask)
    }
    func setDisplayImage(_ ciImage: CIImage) -> Void {
        let parentCtl: PhotoSplitViewController = self.parent as! PhotoSplitViewController
        parentCtl.setDisplayImage(ciImage)
    }
    
    func onNewBrushStroke(_ ciMaskImage: CIImage?) ->Void{
        editToolViewController.onNewBrushStroke(ciMaskImage)
    }
}
