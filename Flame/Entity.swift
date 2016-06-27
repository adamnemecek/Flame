//
//  Entity.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 3/04/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import Foundation

class Entity {
    
    var name: String = "UnnamedEntity"
    var transform: Transform

    private var components = [Component]()
    
    init() {
        self.transform = Transform()
    }
    
    func addComponent<T where T: Component>(type: T.Type) -> T {
        let component = T()
        component.entity = self
        
        components.append(component)
        
        return component
    }

    func addComponent(component: Component) {
        component.entity = self
        components.append(component)
    }
    
    func getComponents<T where T: Component>(type: T.Type) -> [T] {
        return components.filter { $0 is T } as! [T]
    }
    
    func getComponent<T where T: Component>(type: T.Type) -> T? {
        return getComponents(type).first
    }
    
    func update(deltaTime: NSTimeInterval) {
        for component in components {
            component.update(deltaTime)
        }
    }
    
}
