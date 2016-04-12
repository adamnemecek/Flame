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
    
    override func keyDown(theEvent: NSEvent) {
        guard let camera = Scene.sharedInstance.camera?.entity as? Entity else { return }

        let keyCode = Int(theEvent.keyCode & 255)
        let translateSpeed: Float = 0.05
        let rotateSpeed: Float = 0.05

        if keyCode == 0 {
            camera.transform.position.x -= translateSpeed
        }

        if keyCode == 2 {
            camera.transform.position.x += translateSpeed
        }

        if keyCode == 1 {
            camera.transform.position.z += translateSpeed
        }

        if keyCode == 13 {
            camera.transform.position.z -= translateSpeed
        }
 
        if keyCode == 123 { // L
            camera.transform.rotation.y += rotateSpeed
        }

        if keyCode == 124 { // R
            camera.transform.rotation.y -= rotateSpeed
        }

        if keyCode == 126 { // U
            camera.transform.rotation.x += rotateSpeed
        }

        if keyCode == 125 { // D
            camera.transform.rotation.x -= rotateSpeed
        }
    }
    
}