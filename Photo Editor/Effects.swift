/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Encapsulates the CoreImage filters that we expose through the Effects UI
 */

import Cocoa
import CoreImage

enum EffectsList {
    case blur
    case exposure
    case colorControls
    
    var displayName: String {
        switch self {
        case .blur:
            return NSLocalizedString("Masked Blur", comment: "Display name for the blur effect")
     
        case .exposure:
            return NSLocalizedString("Exposure", comment: "Display name for the exposure effect")
            
        case .colorControls:
            return NSLocalizedString("ColorControls", comment: "Display name for the contrast effect")
        }
    }
    
    var filterName: String {
        //private var filterName: String {
        switch self {
        case .blur:
            return "CIMaskedVariableBlur" //"CIGaussianBlur"
            
        case .exposure:
            return "CIExposureAdjust"
            
        case .colorControls:
            return "CIColorControls"
        }
    }

    static var allEffects: [EffectsList] = [.blur, .exposure, .colorControls]
    static var allNonAdjustable: [EffectsList] = [.blur]
}

class Effects {
    
    var mBlur: CIFilter? = nil
    var mExposure: CIFilter? = nil
    var mColorControls: CIFilter? = nil
    
    init() {
        
        mExposure = CIFilter(name: EffectsList.exposure.filterName)
        mExposure?.setDefaults()
        
        mColorControls = CIFilter(name: EffectsList.colorControls.filterName)
        mColorControls?.setDefaults()
        
        //////
        mBlur = CIFilter(name: EffectsList.blur.filterName)
        mBlur?.setDefaults()
    }
    
    convenience init(inputImage: CIImage) {
        self.init()
        mExposure?.setValue(inputImage, forKey: kCIInputImageKey)
        mColorControls?.setValue(mExposure?.outputImage, forKey: kCIInputImageKey)
    }
    
    func outputImage() -> CIImage? {
        
        mColorControls?.setValue(mExposure?.outputImage, forKey: kCIInputImageKey)
        
        return mColorControls?.outputImage
    }
    
    func getExposure(params filterParams: Any? = nil)-> CIFilter{
        return mExposure!
    }
    
    func setExposure(_ exposureParams: Any?)-> Void {
        if exposureParams != nil {
            print("set exposure", exposureParams as! Float)
            mExposure?.setValue(exposureParams as! Float, forKey: "inputEV")
        }
    }
    
    func setContrast(_ contrastParams: Any?)-> Void {
        if contrastParams != nil {
            print("set contrast", contrastParams as! Float)
            mColorControls?.setValue(contrastParams as! Float, forKey: "inputContrast")
            
            //mColorControls?.setValue(mColorControls?.attributes["inputBrightness"], forKey: "inputBrightness")
            //mColorControls?.setValue(mColorControls?.attributes["inputSaturation"], forKey: "inputSaturation")
        }
    }
    
    func setSaturation(_ saturationParams: Any?)-> Void {
        if saturationParams != nil {
            print("set saturation", saturationParams as! Float)
            mColorControls?.setValue(saturationParams as! Float, forKey: "inputSaturation")
            
            //mColorControls?.setValue(mColorControls?.attributes["inputBrightness"], forKey: "inputBrightness")
            //mColorControls?.setValue(mColorControls?.attributes["inputContrast"], forKey: "inputContrast")
        }
    }

    func getFilter(_ effectType: EffectsList, params filterParams: Any? = nil)-> CIFilter {
        switch effectType{
        case EffectsList.exposure:
            return getExposure(params: filterParams)
            
        default:
           let filter = CIFilter(name: effectType.filterName)
            filter?.setDefaults()
            return filter!
        }
    }
}
