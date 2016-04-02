//
//  Notifications.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 3/04/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import Foundation

enum Notification: String {
    case SceneHierarchyChanged = "SceneHierarchyChangedNotification"
}

func postNotification(notification: Notification, object: AnyObject? = nil) {
    NSNotificationCenter.defaultCenter().postNotificationName(notification.rawValue, object: object)
}

func observeNotification(notification: Notification, observer: AnyObject, selector: Selector) {
    NSNotificationCenter.defaultCenter().addObserver(observer, selector: selector, name: notification.rawValue, object: nil)
}

func stopObservingNotifications(observer: AnyObject) {
    NSNotificationCenter.defaultCenter().removeObserver(observer)
}