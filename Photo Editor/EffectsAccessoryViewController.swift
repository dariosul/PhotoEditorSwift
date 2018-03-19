/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Manages the UI for selecting and previewing effects and creates a new image when the button is clicked.
 */

import Cocoa

class EffectsAccessoryViewController: NSTitlebarAccessoryViewController, PhotoControllerConsumer {
    
    @IBOutlet weak var effectSelectionPopUp: NSPopUpButton!
    @IBOutlet weak var applyFilterButton: NSButton!
    
    let filterEffects = Effects()
    var photoController: PhotoController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        effectSelectionPopUp.removeAllItems()
        EffectsList.allEffects.enumerated().forEach { index, effect in
            let item = NSMenuItem(title: effect.displayName, action: nil, keyEquivalent: "")
            item.tag = index
            effectSelectionPopUp.menu!.addItem(item)
        }
    }

    private func imageByApplying(_ filter: CIFilter, to image: NSImage) -> NSImage{
        let sourceImage = CIImage(data: image.tiffRepresentation!)
        filter.setValue(sourceImage, forKey: kCIInputImageKey)
        
        let outputImage = filter.outputImage!
        let result = NSImage(size: image.size)
        let imageRep = NSCIImageRep(ciImage: outputImage)
        result.addRepresentation(imageRep)
        
        return result
    }
    
    @IBAction func btnApplyClicked(_ sender: NSButton) {
        if let image = photoController?.photo.image {
            // set-up the relevant filter with params
            let exposureParam = 0.5 // get value from the exposure slider
            let filter = filterEffects.getFilterWithParams(EffectsList.allEffects[effectSelectionPopUp.selectedTag()], params: exposureParam)
            
            // apply filter to image
            let newImage = imageByApplying(filter, to: image)
            photoController?.setPhotoImage(newImage)
        }
    }

}
