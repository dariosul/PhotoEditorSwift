//
//  EditSplitViewController.swift
//  Photo Editor
//
//  Created by cli mini on 2018-04-09.
//  Copyright © 2018 Apple Inc. All rights reserved.
//
import Cocoa

class EditSplitViewController: NSSplitViewController {
    
    // This method is less generic than our protocol-based approach, but sometimes necessary.
    // Here we assume that at least one child must conform to the desired type; the use of an implicitly-unwrapped optional results in a runtime error if this isn't true.
    
    var editToolViewController: EditToolViewController! {
        return childViewControllers.lazy.filter { $0 is EditToolViewController }.first as? EditToolViewController
    }
    
    var canvasController: CanvasViewController! {
        return childViewControllers.lazy.filter { $0 is CanvasViewController }.first as? CanvasViewController
    }
}