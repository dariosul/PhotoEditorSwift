//
//  BrushToolViewController.swift
//  Photo Editor
//
//  Created by cli mini on 2018-04-09.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import Cocoa

class BrushToolViewController: NSViewController, PhotoControllerConsumer {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.onBrushSizeChange(brushSizeSlider)
        self.onBrushColorChange(brushColorWell)
        self.exposureTextField.floatValue = 0.0
        self.contrastTextFiled.floatValue = 1.0
        self.saturationTextField.floatValue = 1.0
    }
    
    // PhotoSubscriber implementation
    var photoController: PhotoController? {
        didSet {
            if let old = oldValue { old.removeSubscriber(self) }
            if let new = photoController { new.addSubscriber(self) }
        }
    }
    
    @IBOutlet weak var exposureSlider: NSSlider!
    @IBOutlet weak var exposureTextField: NSTextField!
    
    @IBOutlet weak var contrastSlider: NSSlider!
    @IBOutlet weak var contrastTextFiled: NSTextField!
    
    @IBOutlet weak var saturationSlider: NSSlider!
    @IBOutlet weak var saturationTextField: NSTextField!
    
    @IBOutlet weak var brushSizeSlider: NSSlider!
    @IBOutlet weak var brushColorWell: NSColorWell!
    @IBOutlet weak var mShowMask: NSButton!
    
    var filterEffects: Effects? = nil


    @IBAction func onExposureChange(_ sender: Any) {
        if let image = photoController?.photo.image {
            self.validateEffects(image: image)
            
            var exposureValue = (sender as AnyObject).floatValue
            if exposureValue! > Float(2.0) {
                exposureValue = 2.0
            } else if exposureValue! < Float(-2.0) {
                exposureValue = -2.0
            }
            self.exposureSlider.floatValue = exposureValue!
            self.exposureTextField.floatValue = exposureValue!
            filterEffects?.setExposure(exposureValue)
            
            self.updatePreview(size: image.size)
        }
    }
    
    @IBAction func onContrastChange(_ sender: Any) {
        if let image = photoController?.photo.image {
            self.validateEffects(image: image)
            
            var contrastValue = (sender as AnyObject).floatValue
            if contrastValue! > Float(2.0) {
                contrastValue = 2.0
            } else if contrastValue! < Float(0.0) {
                contrastValue = 0.0
            }
            self.contrastSlider.floatValue = contrastValue!
            self.contrastTextFiled.floatValue = contrastValue!
            
            filterEffects?.setContrast(contrastValue)
            
            self.updatePreview(size: image.size)
        }
    }
    
    @IBAction func onSaturationChange(_ sender: Any) {
        if let image = photoController?.photo.image {
            self.validateEffects(image: image)
            
            var saturationValue = (sender as AnyObject).floatValue
            if saturationValue! > Float(2.0) {
                saturationValue = 2.0
            } else if saturationValue! < Float(0.0) {
                saturationValue = 0.0
            }
            self.saturationSlider.floatValue = saturationValue!
            self.saturationTextField.floatValue = saturationValue!
            
            filterEffects?.setSaturation(saturationValue)
            
            self.updatePreview(size: image.size)
        }
    }
    
    func validateEffects(image: NSImage) -> Void {
        if filterEffects == nil {
            let imageData = image.tiffRepresentation!
            let inputImage = CIImage(data: imageData)
            filterEffects = Effects(inputImage: inputImage!)
        }
    }
    
    func updatePreview(size: NSSize) -> Void {
        let ciImage = filterEffects?.outputImage()
        
        // Set display image for canvas image view
        let parentCtl: DevelopSplitViewController = self.parent as! DevelopSplitViewController
        parentCtl.setDisplayImage(ciImage!)
    }
    
    @IBAction func onBrushSizeChange(_ sender: NSSlider) {
        // Set brush size for brush paint view
        let parentCtl: DevelopSplitViewController = self.parent as! DevelopSplitViewController
        parentCtl.setBrushSize(sender.floatValue)
    }
    
    @IBAction func onBrushColorChange(_ sender: NSColorWell) {
        // Set brush color for brush paint view
        let parentCtl: DevelopSplitViewController = self.parent as! DevelopSplitViewController
        parentCtl.setBrushColor(sender.color)
    }

    
    
    @IBAction func onShowMask(_ sender: NSButtonCell) {
        // Set brush color for brush paint view
        let parentCtl: DevelopSplitViewController = self.parent as! DevelopSplitViewController
        parentCtl.setShowMask(sender.state == NSOnState)
    }

    func onNewBrushStroke(_ ciMaskImage: CIImage?) ->Void{

        if let image = photoController?.photo.image {
            self.validateEffects(image: image)
            
            filterEffects?.mMaskImage = ciMaskImage
            
            if (mShowMask.state != NSOnState){
                self.updatePreview(size: image.size)
            }
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
}

extension BrushToolViewController: PhotoSubscriber {
    
    func photo(_ photo: Photo, didChangeImage image: NSImage?, from oldImage: NSImage?) {
        
        // Do clean up when select another image
        self.filterEffects = nil
        exposureSlider.floatValue = 0.0
        exposureTextField.floatValue = 0.0
        
        contrastSlider.floatValue = 1.0
        contrastTextFiled.floatValue = 1.0
        
        saturationSlider.floatValue = 1.0
        saturationTextField.floatValue = 1.0
    }
    
    func photo(_ photo: Photo, didChangeTitle title: String) {
        // Do nothing
    }
}
