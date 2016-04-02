//
//  ViewController.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 27/03/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import Cocoa

class ViewController: NSViewController,
    NSTableViewDataSource, NSTableViewDelegate {
 
    @IBOutlet weak var metalViewContainer: NSView!
    @IBOutlet weak var sceneTableView: NSTableView!

    var metalView: MetalView?

    private var cellIdentifier = "EntityCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let metalView = MetalView(size: metalViewContainer.frame.size) {
            metalView.autoresizingMask = [.ViewWidthSizable, .ViewHeightSizable]
            metalViewContainer.addSubview(metalView)
            self.metalView = metalView
        }
        
        sceneTableView.setDataSource(self)
        sceneTableView.setDelegate(self)
        sceneTableView.reloadData()

        sceneTableView.backgroundColor = NSColor(calibratedRed: 0.07, green: 0.08, blue: 0.1, alpha: 1.0)
        
        observeNotification(.SceneHierarchyChanged, observer: self, selector: "sceneHierarchyChanged")
    }
    
    deinit {
        stopObservingNotifications(self)
    }

    // MARK: - Public API
    
    func sceneHierarchyChanged() {
        sceneTableView.reloadData()
    }
    
    // MARK: - NSTableViewDataSource
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return Scene.sharedInstance.entities.count
    }

    // MARK: - NSTableViewDelegate
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let entity = Scene.sharedInstance.entities[row]
        
        if let cell = tableView.makeViewWithIdentifier(cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = entity.name
            cell.textField?.textColor = NSColor.grayColor()
            return cell
        }

        return nil
    }
    
}
