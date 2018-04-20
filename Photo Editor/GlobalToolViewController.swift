//
//  GlobalToolViewController.swift
//  Photo Editor
//
//  Created by cli mini on 2018-04-19.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import Cocoa

class GlobalToolViewController: NSViewController, PhotoControllerConsumer {
    
    var gDevelopSettings: NSDictionary = NSDictionary()
    var effects: Effects? = nil
    
    @IBOutlet weak var gExposureSlider: NSSlider!
    @IBOutlet weak var gContrastSlider: NSSlider!
    @IBOutlet weak var gSaturationSlider: NSSlider!
    
    @IBOutlet weak var gExposureTextField: NSTextField!
    @IBOutlet weak var gContrastTextField: NSTextField!
    @IBOutlet weak var gSaturationTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.gExposureTextField.floatValue = 0.0
        self.gContrastTextField.floatValue = 1.0
        self.gSaturationTextField.floatValue = 1.0
    }
    
    // PhotoSubscriber implementation
    var photoController: PhotoController? {
        didSet {
            if let old = oldValue { old.removeSubscriber(self) }
            if let new = photoController { new.addSubscriber(self) }
        }
    }
    
    func validateEffects(image: NSImage) -> Void {
        if effects == nil {
            let imageData = image.tiffRepresentation!
            let inputImage = CIImage(data: imageData)
            effects = Effects(inputImage: inputImage!)
        }
    }
    
    func updatePreview(size: NSSize) -> Void {
        let ciImage = effects?.outputImage()
        
        // Set display image for canvas image view
        let parentCtl: DevelopSplitViewController = self.parent as! DevelopSplitViewController
        parentCtl.setDisplayImage(ciImage!)
    }
    
    @IBAction func onExposureChange(_ sender: Any) {
        if let image = photoController?.photo.image {
            self.validateEffects(image: image)
        
            var exposureValue = (sender as AnyObject).floatValue
            if exposureValue! > Float(2.0) {
                exposureValue = 2.0
            } else if exposureValue! < Float(-2.0) {
                exposureValue = -2.0
            }
            self.gExposureSlider.floatValue = exposureValue!
            self.gExposureTextField.floatValue = exposureValue!
            effects?.setExposure(exposureValue)

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
            self.gContrastSlider.floatValue = contrastValue!
            self.gContrastTextField.floatValue = contrastValue!
            
            effects?.setContrast(contrastValue)

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
            self.gSaturationSlider.floatValue = saturationValue!
            self.gSaturationTextField.floatValue = saturationValue!
            
            effects?.setSaturation(saturationValue)

            self.updatePreview(size: image.size)
        }
    }
}

extension GlobalToolViewController: PhotoSubscriber {
    
    func photo(_ photo: Photo, didChangeImage image: NSImage?, from oldImage: NSImage?) {
        
        // Do clean up when select another image
        self.effects = nil
        gExposureSlider.floatValue = 0.0
        gExposureTextField.floatValue = 0.0

        gContrastSlider.floatValue = 1.0
        gContrastTextField.floatValue = 1.0

        gSaturationSlider.floatValue = 1.0
        gSaturationTextField.floatValue = 1.0
    }
    
    func photo(_ photo: Photo, didChangeTitle title: String) {
        // Do nothing
    }
}
