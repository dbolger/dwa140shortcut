//
//  AppDelegate.swift
//  DWA140Menu
//
//  Created by FivePixels on 9/3/18.
//  Copyright © 2018 FivePixels. All rights reserved.
//

import Cocoa
import Foundation
import SystemConfiguration

let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
var interfaceName : String = ""
let dynRef = SCDynamicStoreCreate(kCFAllocatorSystemDefault, "iked" as CFString, nil, nil)
let ipv4key = SCDynamicStoreCopyValue(dynRef, "State:/Network/Global/IPv4" as CFString)
var isDeviceInterfaceConnected : Bool?
let applicationStoryboard = NSStoryboard(name: "Main", bundle: nil)
let mainWindowController = applicationStoryboard.instantiateController(withIdentifier: "MainWindowController") as! NSWindowController
let mainViewController = applicationStoryboard.instantiateController(withIdentifier: "MainViewController") as! NSViewController
let tabViewController = applicationStoryboard.instantiateController(withIdentifier: "TabViewController") as! NSTabViewController

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
    
    @objc func openApplicationWindow() {
        if mainWindowController.window?.isVisible == false {
            mainWindowController.showWindow(self)
            NSApp.activate(ignoringOtherApps: true)
        } else {
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    @objc func openDWAPreferencePane() {
        let fileManager = FileManager.default
        let allUsersPath = "/Library/PreferencePanes/DWA-140WirelessUtility.prefpane"
        let currentUserPath = "~/Library/PreferencePanes/DWA-140WirelessUtility.prefPane"
        if fileManager.fileExists(atPath: allUsersPath) {
            NSWorkspace.shared.open(URL(fileURLWithPath: allUsersPath)) }
        else if fileManager.fileExists(atPath: currentUserPath) {
            NSWorkspace.shared.open(URL(fileURLWithPath: currentUserPath))
        } else {
            showNotification(title: "DWA-140 Shortcut Error", withText: "The preference pane does not exist.")
        }
    }
    
    @objc func openNetworkPreferencePane() {
        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/PreferencePanes/Network.prefPane"))
    }
    
    @objc func refreshApplication() {
        let url = URL(fileURLWithPath: Bundle.main.resourcePath!)
        let path = url.deletingLastPathComponent().deletingLastPathComponent().absoluteString
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [path]
        task.launch()
        exit(0)
    }
    
    @objc func showNotification(title: String, withText: String) -> Void {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = withText
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.delegate = self
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    func getInterface() -> String {
        // thanks NetUtils-Swift :p
        if var dict1 = ipv4key as? [String: AnyObject] {
            if (dict1["PrimaryInterface"] == nil) {
                interfaceName = "none"
            }
            interfaceName = (dict1["PrimaryInterface"] as! String)
        }
        return interfaceName
    }
    
    func constructMenu() {
        let applicationMenu = NSMenu()
        applicationMenu.addItem(NSMenuItem(title: "DWA-140 Shortcut", action: #selector(openApplicationWindow), keyEquivalent: ""))
        applicationMenu.addItem(NSMenuItem.separator())
        applicationMenu.addItem(NSMenuItem(title: isInterfaceConnected(), action: nil, keyEquivalent: ""))
        applicationMenu.addItem(NSMenuItem.separator())
        applicationMenu.addItem(NSMenuItem(title: "Refresh Status", action: #selector(refreshApplication), keyEquivalent: "r"))
        applicationMenu.addItem(NSMenuItem(title: "Open DWA-140", action: #selector(openDWAPreferencePane), keyEquivalent: "t"))
        applicationMenu.addItem(NSMenuItem(title: "Network Preferences", action: #selector(openNetworkPreferencePane), keyEquivalent: ""))
        applicationMenu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))
        statusItem.menu = applicationMenu
        
    }
    
    func isInterfaceConnected() -> String {
        if getInterface() == "en0" {
            isDeviceInterfaceConnected = true
            DispatchQueue.main.async {
                self.setStatusIcon(icon: "WiFiConnected")
            }
            return "USB WiFi is connected."
        } else {
            isDeviceInterfaceConnected = false
            DispatchQueue.main.async {
                self.setStatusIcon(icon: "WiFiDisconnected")
            }
            return "USB Wifi is disconnected."
        }
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter,
                                shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        constructMenu()
    }
    
    func setStatusIcon(icon: String) {
        if let button = statusItem.button {
            if button.image?.name() != icon {
                button.image = NSImage(named: NSImage.Name(icon))
            }
        }
    }
}
