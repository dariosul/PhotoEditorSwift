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
    
    var editSplitViewController: EditSplitViewController! {
        return childViewControllers.lazy.filter { $0 is EditSplitViewController }.first as? EditSplitViewController
    }
    
}
