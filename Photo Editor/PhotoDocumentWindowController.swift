/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The PhotoDocumentWindowController controls the main window and references the NSDocument. It stores the current top level edit mode.
 */


import Cocoa

class PhotoDocumentWindowController: NSWindowController, NSWindowDelegate, MouseDraw {
    
//    enum EditMode: Int {
//        case move
//        case draw
//        case effects
//    }
    
    enum ZoomSegment: Int {
        case zoomOut
        case actualSize
        case zoomIn
    }
    
    @IBOutlet weak var modeSelectionControl: NSSegmentedControl!
    
    var splitViewController: PhotoSplitViewController! { return contentViewController as? PhotoSplitViewController }
//    private var effectsAccessoryViewController: EffectsAccessoryViewController!
    
    var photoController: PhotoController? {
        willSet {
            photoController?.removeSubscriber(self)
        }
        
        didSet {
            // We want to abstractly push state down the view controller hierarchy; we walk down the chain and assign the controller to the children that need it
            func propagateToChildren(of parent: NSViewController) {
                if var photoControllerConsumer: PhotoControllerConsumer = parent as? PhotoControllerConsumer {
                    photoControllerConsumer.photoController = photoController
                }
                for childVC in parent.childViewControllers {
                    propagateToChildren(of: childVC)
                }
            }
            
            // Push down from our contentViewController to all children
            propagateToChildren(of: contentViewController!)
            
            // Push to our titlebar accessory view controllers
            splitViewController.editSplitViewController.editToolViewController.photoController = photoController
//            effectsAccessoryViewController.photoController = photoController
            
            // Subscribe to photo changes
            photoController?.addSubscriber(self)
        }
    }
    
    override var document: AnyObject? {
        didSet {
            guard let photoDocument = document as? PhotoDocument else { return }
            if photoDocument.photo == nil {
                photoDocument.photo = Photo()
            }
            photoController = PhotoController(photo: photoDocument.photo!)
        }
    }
    
//    var editMode: EditMode = .effects
    
    var appearanceObservationToken: NSObjectProtocol?
    
    //MARK: Window Lifecycle
    
    deinit {
        if let token = appearanceObservationToken {
            NotificationCenter.default.removeObserver(token)
        }
        
        splitViewController.editSplitViewController.canvasController.removeSubscriber(self)
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        let window = self.window!
        let storyboard = self.storyboard!
        
        // Similarly, set up the effects titlebar accessory
//        let effectsAccessory = storyboard.instantiateController(withIdentifier: "EffectsConfigurationAccessory") as! EffectsAccessoryViewController
//        window.addTitlebarAccessoryViewController(effectsAccessory)
//        effectsAccessory.isHidden = false
//        effectsAccessoryViewController = effectsAccessory
        
        // Hide the titlebar for the streamlined toolbar look
        // Comment this out to show the title (file name) of the window
        window.titleVisibility = .hidden
        
        // If the title isn't hidden, add an accessory view controller; otherwise we would probably add it to the toolbar directly when using the "streamlined toolbar" (aka: hidden title)
        if window.titleVisibility == .visible {
            let rightSideAccesoryViewController = storyboard.instantiateController(withIdentifier: "RightSideAccesoryViewController") as! NSTitlebarAccessoryViewController
            rightSideAccesoryViewController.layoutAttribute = .trailing
            window.addTitlebarAccessoryViewController(rightSideAccesoryViewController)
        }
        
        // Configure the initial appearance
        updateWindowAppearance()
        
        // Watch for changes in the appearance
        appearanceObservationToken = NotificationCenter.default.addObserver(forName: .appearanceChanged, object: nil, queue: nil) { [weak self] _ in
            self?.updateWindowAppearance()
        }
        
        splitViewController.editSplitViewController.canvasController.addSubscriber(self)
    }
    
    // State restoration example: Save and restore the edit mode property
//    override func encodeRestorableState(with coder: NSCoder) {
//        super.encodeRestorableState(with: coder)
//        coder.encode(editMode.rawValue, forKey: "EditMode")
//    }
//
//    override func restoreState(with coder: NSCoder) {
//        super.restoreState(with: coder)
//        if let editMode = EditMode(rawValue: coder.decodeInteger(forKey: "EditMode")) {
//            self.editMode = editMode
//        }
//    }
    
    private func updateWindowAppearance() {
        // See Defaults.swift for a definition of useDarkMode
        if (UserDefaults.useDarkMode) {
            window?.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
        } else {
            window?.appearance = nil // Goes back to the default Aqua appearance
        }
    }
    
    func updateBrushPoints(mousePoints points: [CGPoint]) {
//        effectsAccessoryViewController.addBrushPoints(mousePoints: points)
    }
}

//MARK: UI Actions
extension PhotoDocumentWindowController : NSUserInterfaceValidations {
    
    // Validate the user interface items that we implement
    func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
        if let action = item.action {
            if action == #selector(PhotoDocumentWindowController.setImageSize(_:)) {
                // Only validate the item if we have a photo
                return photoController?.photo.image != nil
            }
        }
        return true // default to things being enabled
    }
    
    
    // The menu item for the image size is hooked up to the firstResponder with an action of "setImageSize:"
    @IBAction func setImageSize(_ sender: AnyObject!) {
        // We want to assert if this can't be loaded
        let sizeViewController = storyboard?.instantiateController(withIdentifier: "ImageSizeController") as! ImageSizeViewController
        
        // The validation method above should ensure we have an image
        let photoController = self.photoController!
        let image: NSImage = photoController.photo.image as NSImage!
        sizeViewController.imageSize = image.size
        sizeViewController.completionHandler = { size, response in
            if response == NSModalResponseOK {
                // We resize the image by redrawing it into a new image and assigning it to the photo controller
                let newImage = NSImage(size: size)
                newImage.lockFocusFlipped(true)
                image.draw(in: NSRect(x: 0, y: 0, width: size.width, height: size.height))
                newImage.unlockFocus()
                
                photoController.setPhotoImage(newImage)
            }
        }
        
        // Show it as a sheet
        contentViewController!.presentViewControllerAsSheet(sizeViewController)
    }
    
//    @IBAction func didChangeEditingMode(_ sender: AnyObject!) {
//        let rawValue: Int
//
//        if sender.isEqual(modeSelectionControl) {
//            rawValue = modeSelectionControl.selectedSegment
//        } else {
//            rawValue = sender.tag
//            modeSelectionControl.selectedSegment = rawValue
//        }
//
//        if let mode = EditMode(rawValue: rawValue) {
//            editMode = mode
//
//            // Go through all our windows in the same tab and sync the value; this is just an example of how to do something like this
//            if let tabbedWindows = window?.tabbedWindows {
//                for otherWindow in tabbedWindows {
//                    if let otherWindowController = otherWindow.windowController as? PhotoDocumentWindowController {
//                        if (otherWindowController != self) {
//                            otherWindowController.editMode = mode
//                            otherWindowController.modeSelectionControl.selectedSegment = rawValue
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    @IBAction func didPressZoomSegment(_ sender: NSSegmentedControl!) {
        guard let segment = ZoomSegment(rawValue: sender.selectedSegment) else { return }
        
        switch segment {
            case .zoomOut:
                zoomOut(sender)
            break
            
            case .actualSize:
                zoomImageToActualSize(sender)
            break
            
            case .zoomIn:
                zoomIn(sender)
            break
        }
    }
    
    @IBAction func zoomIn(_ sender: AnyObject!) {
        splitViewController.editSplitViewController.canvasController.zoomIn(sender)
    }
    
    @IBAction func zoomOut(_ sender: AnyObject!) {
        splitViewController.editSplitViewController.canvasController.zoomOut(sender)
    }
    
    @IBAction func zoomImageToActualSize(_ sender: AnyObject!) {
        splitViewController.editSplitViewController.canvasController.zoomImageToActualSize(sender)
    }
    
}

//MARK: Photo Subscriber Protocol
extension PhotoDocumentWindowController: PhotoSubscriber {
    
    func photo(_ photo: Photo, didChangeImage image: NSImage?, from oldImage: NSImage?) {
        if let document = self.document {
            if let undoManager = document.undoManager {
                undoManager?.registerUndo(withTarget: self) { targetType in
                    targetType.photoController?.setPhotoImage(oldImage)
                }
            }
            document.updateChangeCount(.changeDone)
        }
    }
    
    func photo(_ photo: Photo, didChangeTitle title: String) {
        document?.updateChangeCount(.changeDone)
    }

}

