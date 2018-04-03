/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Encapsulates the CoreImage filters that we expose through the Effects UI
 */

import Cocoa
import CoreImage
//import CustomFilter

enum EffectsList {
    case blur
    case invert
    case monochrome
    case exposure
    
    var displayName: String {
        switch self {
        case .blur:
            return NSLocalizedString("Masked Blur", comment: "Display name for the blur effect")
            
        case .invert:
            return NSLocalizedString("Invert Colors", comment: "Display name for the invert effect")
            
        case .monochrome:
            return NSLocalizedString("Black & White", comment: "Display name for the monochrome effect")
            
        case .exposure:
            return NSLocalizedString("Exposure", comment: "Display name for the monochrome effect")
        }
    }
    
    var filterName: String {
        //private var filterName: String {
        switch self {
        case .blur:
            return "CIMaskedVariableBlur" //"CIGaussianBlur"
            
        case .invert:
            return "CIColorInvert"
            
        case .monochrome:
            return "CIPhotoEffectMono"
            
        case .exposure:
            return "CIExposureAdjust"
            
        }
    }

    static var allEffects: [EffectsList] = [.blur, .invert, .monochrome, .exposure]
    static var allNonAdjustable: [EffectsList] = [.blur, .invert, .monochrome]
}

class Effects {
    
    var mBlur: CIFilterWithMask? = nil
    var mInvertColors: CIFilterWithMask? = nil
    var mEffectMonoChrome: CIFilterWithMask? = nil
    var mExposure: CIFilterWithMask? = nil
    
    func getExposure(params filterParams: Any? = nil)-> CIFilterWithMask{
        if (mExposure == nil)
        {
            mExposure = CIFilterWithMask(name: EffectsList.exposure.filterName)
            mExposure?.setDefaults()
        }
        setExposure(filterParams)
        return mExposure!
    }
    
    func setExposure(_ exposureParams: Any?)-> Void{
        if exposureParams != nil {
            mExposure?.setValue(exposureParams as! Float, forKey: "inputEV")
        }
    }

    func getFilter(_ effectType: EffectsList, params filterParams: Any? = nil)-> CIFilterWithMask{
        switch effectType{
        case EffectsList.exposure:
            return getExposure(params: filterParams)
//
//        case EffectsList.blur:
//            return mBlur!
//
//        case EffectsList.invert:
//            return mInvertColors!
//
//        case EffectsList.monochrome:
//            return mEffectMonoChrome!
            
        default:
           let filter = CIFilterWithMask(name: effectType.filterName)
            filter?.setDefaults()
            return filter!
        }
    }
}
