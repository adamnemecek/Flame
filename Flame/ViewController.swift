//
//  ViewController.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 27/03/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
 
    @IBOutlet weak var metalViewContainer: NSView!

    var metalView: MetalView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let metalView = MetalView(size: metalViewContainer.frame.size) {
            metalView.autoresizingMask = [.ViewWidthSizable, .ViewHeightSizable]
            metalViewContainer.addSubview(metalView)
            self.metalView = metalView
        }
    }

}
