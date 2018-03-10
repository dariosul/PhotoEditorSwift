/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Defaults is a nice wrapper around NSUserDefaults and declares our global user defaults (useDarkMode)
 */

import Cocoa

struct PreferenceKey<Value> : RawRepresentable {
    typealias RawValue = String 
    let rawValue: RawValue
    
    init (_ key: String) {
        rawValue = key
    }
    
    // Appease the protocol.
    init (rawValue: RawValue) {
        self.rawValue = rawValue
    }
    
}

extension Notification.Name {
    static let appearanceChanged = Notification.Name(rawValue: "AppearanceChangedNotification")
}

extension UserDefaults {
    subscript(key: PreferenceKey<Bool>) -> Bool {
        set { set(newValue, forKey: key.rawValue) }
        get { return bool(forKey: key.rawValue) }
    }
    
    subscript(key: PreferenceKey<Float>) -> Float {
        set { set(newValue, forKey: key.rawValue) }
        get { return float(forKey: key.rawValue) }
    }
    
    subscript(key: PreferenceKey<Double>) -> Double {
        set { set(newValue, forKey: key.rawValue) }
        get { return double(forKey: key.rawValue) }
    }
    
    subscript(key: PreferenceKey<Int>) -> Int {
        set { set(newValue, forKey: key.rawValue) }
        get { return integer(forKey: key.rawValue) }
    }
}

// User defaults for our application
extension UserDefaults {
    static let useDarkModeKey = PreferenceKey<Bool>("UseDarkMode")
    
    static var useDarkMode: Bool {
        get {
            return UserDefaults.standard[useDarkModeKey]
        }
    }
}

