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
        EffectsList.allEffects.enumerated().forEach { index, effect in
            let item = NSMenuItem(title: effect.displayName, action: nil, keyEquivalent: "")
            item.tag = index
            effectSelectionPopUp.menu!.addItem(item)
        }
        
        mExposureSlider.isEnabled = false
    }
    
    @IBAction func onItemChanged(_ sender: NSPopUpButton) {
        if  effectSelectionPopUp.selectedItem!.title == EffectsList.exposure.displayName {
            mExposureSlider.isEnabled = true
            runExposurePreview()
        } else{
            mExposureSlider.isEnabled = false
            // discard exposure preview
            photoController?.setPhotoImage(photoController?.photo.cachedImage)
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
    
    // this will make an exposure preview that runs on a previously commited image
    func runExposurePreview(){
        if let image = photoController?.photo.cachedImage {
            let val = mExposureSlider.floatValue
            let filter = filterEffects.getExposure(params: val)
            let newImage = imageByApplying(filter, to: image)
            photoController?.setPhotoImage(newImage)
        }
    }
    
    @IBAction func onExposureSlider(_ sender: NSSlider) {
        runExposurePreview()
    }
    
    @IBAction func btnApplyClicked(_ sender: NSButton) {
        if let image = photoController?.photo.image {
            let filter = filterEffects.getFilter(EffectsList.allEffects[effectSelectionPopUp.selectedTag()])
            let newImage = imageByApplying(filter, to: image)
            photoController?.setCommitPhotoImage(newImage)
        }
    }

}
