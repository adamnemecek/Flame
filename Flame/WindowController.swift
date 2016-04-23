//
//  WindowController.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 27/03/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import Foundation
import AppKit

class WindowController : NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()

        guard let appVersion = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] else {
            print("⚠️ Couldn't read app version from infoDictionary.")
            return
        }
        
        window?.title = "Flame 🔥 \(appVersion)"
    }

    override func keyDown(event: NSEvent) {
        Input.sharedInstance.registerKeyDown(event.keyCode)
    }
    
    override func keyUp(event: NSEvent) {
        Input.sharedInstance.registerKeyUp(event.keyCode)
    }
   
}