//
//  AppDelegate.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 27/03/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(aNotification: NSNotification) {

        Scene.sharedInstance.setup()
        
        if let file = NSBundle.mainBundle().pathForResource("testmap", ofType: "bsp"),
           let bsp = QuakeBSP(filePath: file) {
            
            print("BSP version: \(bsp.version)")
            print("Parsed \(bsp.entities.count) entities")
        
        }
        else {
            print("⚠️ Failed to parse BSP file.")
        }

        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
}

