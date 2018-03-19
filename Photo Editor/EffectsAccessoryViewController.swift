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
    

    @IBOutlet weak var mExposureSlider: NSSlider!
    
    let filterEffects = Effects()
    var photoController: PhotoController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        effectSelectionPopUp.removeAllItems()
        EffectsList.allNonAdjustable.enumerated().forEach { index, effect in
            let item = NSMenuItem(title: effect.displayName, action: nil, keyEquivalent: "")
            item.tag = index
            effectSelectionPopUp.menu!.addItem(item)
        }
        
        self.setupExposure()
    }
    
    private func setupExposure(){
        //mExposureSlider.setValue(mExposureSlider.floatValue/4.0, forKey: "CIAttributeSliderMin")
        //mExposureSlider.setValue(mExposureSlider.floatValue/4.0, forKey: "CIAttributeSliderMax")
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
    @IBAction func onExposureSlider(_ sender: NSSlider) {
        if let image = photoController?.photo.image {
            let val = mExposureSlider.floatValue/10.0
            let filter = filterEffects.getExposure(params: val)
            let newImage = imageByApplying(filter, to: image)
            photoController?.setPhotoImage(newImage)
        }
    }
    
    @IBAction func btnApplyClicked(_ sender: NSButton) {
        if let image = photoController?.photo.image {
            let filter = filterEffects.getFilter(EffectsList.allNonAdjustable[effectSelectionPopUp.selectedTag()])
            let newImage = imageByApplying(filter, to: image)
            photoController?.setPhotoImage(newImage)
        }
    }

}
