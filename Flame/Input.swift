//
//  Input.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 23/04/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import Foundation

class Input {
    
    static let sharedInstance = Input()
    
    private var pressedKeys = Set<UInt16>()
    
    func registerKeyDown(keyCode: UInt16) {
        pressedKeys.insert(keyCode)
    }
    
    func registerKeyUp(keyCode: UInt16) {
        pressedKeys.remove(keyCode)
    }
    
    func isKeyDown(keyCode: UInt16) -> Bool {
        return pressedKeys.contains(keyCode)
    }
}
