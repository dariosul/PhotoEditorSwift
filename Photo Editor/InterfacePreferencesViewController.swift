/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 InterfacePreferencesViewController is a basic view controller to control the system settings. The "dark mode" check box is bound to the user defaults with the key "UseDarkMode". When the value changes a notification is manually sent out so all windows can switch to a dark mode.
*/

import Cocoa

class InterfacePreferencesViewController: NSViewController {
    
    @IBAction func didToggleDarkMode(_ sender: NSButton) {
        // The button is bound to the user default value "UseDarkMode". We send a notification when the value changes so the app can update its state based on it.
        NotificationCenter.default.post(name: .appearanceChanged, object: nil)
    }
}
