//
//  CIImageExtensions.swift
//  Photo Editor
//
//  Created by cli mini on 2018-04-18.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import Cocoa

extension NSImage {
    
    /* Convert NSImage to CIImage
     */
    public func convertToCIImage() -> CIImage {
        
        // create CIImage from cgImage
        let imageData = self.tiffRepresentation
        let sourceData = CGImageSourceCreateWithData(imageData! as CFData, nil)
        let cgImage: CGImage? = CGImageSourceCreateImageAtIndex(sourceData!, 0, nil)
        let ciImage: CIImage? = CIImage(cgImage: cgImage!)
        
        
        // create CIImage from bitmap
//        let bitmap = NSBitmapImageRep(data: imageData!)
//        let ciImage: CIImage? = CIImage(bitmapImageRep: bitmap!)
        
        return ciImage!
        
        /*
        // create affine transform to flip CIImage
        let affineTransform = NSAffineTransform()
        affineTransform.translateX(by: 0, yBy: 0)
        affineTransform.scaleX(by: 1, yBy: 1)
        
        // create CIFilter with embedded affine transform
        let transform = CIFilter(name: "CIAffineTransform")
        transform?.setValue(ciImage, forKey: "inputImage")
        transform?.setValue(affineTransform, forKey: "inputTransform")
        
        return (transform?.outputImage)!
         */
    }
}
