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
    case invert
    case monochrome
    case exposure
    
    var displayName: String {
        switch self {
        case .blur:
            return NSLocalizedString("Blur", comment: "Display name for the blur effect")
            
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
            return "CIGaussianBlur"
            
        case .invert:
            return "CIColorInvert"
            
        case .monochrome:
            return "CIPhotoEffectMono"
            
        case .exposure:
            return "CIExposureAdjust"
            
        }
    }

    static var allEffects: [EffectsList] = [.blur, .invert, .monochrome, .exposure]
//    static var allNonAdjustable: [EffectsList] = [.blur, .invert, .monochrome]
}

class Effects {
    
    var mBlur: CIFilter? = nil
    var mInvertColors: CIFilter? = nil
    var mEffectMonoChrome: CIFilter? = nil
    var mExposure: CIFilter? = nil
    
    var mAllFilters: [EffectsList: CIFilter?]
    
    
    init(){
        mAllFilters = [EffectsList.blur: self.mBlur, EffectsList.invert: self.mInvertColors, EffectsList.monochrome: self.mEffectMonoChrome, EffectsList.exposure: self.mExposure]
    }
    
    func getExposure(params filterParams: Any? = nil)-> CIFilter{

        if (mExposure == nil)
        {
            mExposure = getFilter(EffectsList.exposure)
        }
        setExposure(filterParams)
        return mExposure!
    }
    
    func setExposure(_ exposureParams: Any?)-> Void{
        if exposureParams != nil {
            mExposure?.setValue(exposureParams as! Float, forKey: "inputEV")
        }
    }

    func getFilter(_ effectType: EffectsList) -> CIFilter {
        var filter = mAllFilters[effectType]!
        
        if filter == nil {
            filter = CIFilter(name: effectType.filterName)
            filter?.setDefaults()
        }
            
        return filter!
    }
}
