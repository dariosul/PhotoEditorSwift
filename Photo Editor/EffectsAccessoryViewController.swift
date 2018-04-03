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
    
    @IBOutlet weak var mBrushWidth: NSSlider!
    
    //var mShowMask = false
    
    @IBOutlet weak var mShowMask: NSButton!
    
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
        switch EffectsList.allEffects[effectSelectionPopUp.selectedTag()] {
        case EffectsList.exposure:
            mExposureSlider.isEnabled = true
            runExposurePreview()
            
        default:
            mExposureSlider.isEnabled = false
            // discard exposure preview
            photoController?.setPhotoImage(photoController?.photo.cachedImage)
        }
    }
    
    private func imageByApplying(_ filter: CIFilter, to image: NSImage) -> NSImage{
        let sourceImage = CIImage(data: image.tiffRepresentation!)
        
        filter.setValue(sourceImage, forKey: "inputImage")
        
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
    
    func runMaskedBlur(mousePoints points: [CGPoint]){
        var baseImage : NSImage
        var maskColor: CIColor
        
        if (mShowMask.state == NSOnState){
            baseImage = (photoController?.photo.image)!
            maskColor = CIColor(red: 1, green: 0, blue: 0, alpha: 0.7) // show mask in red color
        }
        else{
            baseImage = (photoController?.photo.cachedImage)!
            maskColor = CIColor(red: 1, green: 1, blue: 1) // masked blur will need grey mask
        }
        
        // brush min - max values are percentages of image dimentions
        let brushDiameter = Float(max (baseImage.size.width, baseImage.size.height)) * mBrushWidth.floatValue / 100
        
        var maskImage: CIImage? =  nil
        for blurCenter in points{
            // draw the radial gradient mask instead of image
            let gradientFilter = CIFilter(name: "CIRadialGradient",
                                          withInputParameters: [
                                            kCIInputCenterKey: CIVector(x: blurCenter.x, y: blurCenter.y),
                                            "inputRadius0": brushDiameter/2 - 1.0,
                                            "inputRadius1": brushDiameter/2, //  this will be nib width and feathering, no feathering now
                                            "inputColor0": maskColor,
                                            "inputColor1": CIColor(red: 0, green: 0, blue: 0, alpha: 0)])!
            
            guard let outCIImage = gradientFilter.outputImage else {return}
            
            if maskImage == nil{
                maskImage = outCIImage
            }
            else{
                maskImage = CIFilter(name:"CISourceOverCompositing", withInputParameters:["inputImage":outCIImage, "inputBackgroundImage": maskImage!])!.outputImage
            }
        }
        
        let result = NSImage(size: baseImage.size)
        let sourceImage = CIImage(data: baseImage.tiffRepresentation!)
            
        if (mShowMask.state == NSOnState){
            
            let blendCI = CIFilter(name:"CISourceOverCompositing", withInputParameters:["inputImage": maskImage!, "inputBackgroundImage": sourceImage! ])!
            let blendCIImage = blendCI.outputImage!

            let imageRep = NSCIImageRep(ciImage: blendCIImage)
            result.addRepresentation(imageRep)
            photoController?.setPhotoImage(result)
            
        }else{
            let maskedVariableBlurParams : [String : AnyObject] = [kCIInputImageKey: sourceImage!, "inputRadius": 10.0 as AnyObject, "inputMask" : maskImage!]

            let filter = CIFilter(name: "CIMaskedVariableBlur", withInputParameters: maskedVariableBlurParams)!;

            let outputImage = filter.outputImage!

            let imageRep = NSCIImageRep(ciImage: outputImage)
            result.addRepresentation(imageRep)
            photoController?.setCommitPhotoImage(result)
        }
    }
    
    @IBAction func onExposureSlider(_ sender: NSSlider) {
        runExposurePreview()
    }
    
    @IBAction func btnApplyClicked(_ sender: NSButton) {
            if EffectsList.allEffects[effectSelectionPopUp.selectedTag()] == EffectsList.blur{
                //runMaskedBlur()
            }else{
                // this is an image you see on the screen
                if let image = photoController?.photo.image {
                    let filter = filterEffects.getFilter(EffectsList.allEffects[effectSelectionPopUp.selectedTag()])

                    let newImage = imageByApplying(filter, to: image)
                    photoController?.setCommitPhotoImage(newImage)
            }
        }
    }
    
    func addBrushPoints(mousePoints points: [CGPoint]){
        if EffectsList.allEffects[effectSelectionPopUp.selectedTag()] == EffectsList.blur{
            runMaskedBlur(mousePoints: points)
        }
    
    }

}
