//
//  AppDelegate.swift
//  DWA140Menu
//
//  Created by FivePixels on 9/3/18.
//  Copyright © 2018 FivePixels. All rights reserved.
//

import Cocoa
import Foundation
import Defaults
import LaunchAtLogin
import SystemConfiguration

extension Defaults.Keys {
    static let launchAtLogin = Defaults.Key<Bool>("launchAtLogin", default: false)
}

let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
var launchAtLoginMenuItem = NSMenuItem()
var interfaceName : String = ""
let dynRef = SCDynamicStoreCreate(kCFAllocatorSystemDefault, "iked" as CFString, nil, nil)
let ipv4key = SCDynamicStoreCopyValue(dynRef, "State:/Network/Global/IPv4" as CFString)
var isDeviceInterfaceConnected : Bool?
var deviceIPAddress : String = ""

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
    
    @objc func openSourcePage() {
        NSWorkspace.shared.open((URL(string:"https://github.com/fivepixels/dwa140shortcut") ?? nil)!)
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
    
    @objc func toggleLaunchAtLogin() {
        let launchAtLogin = defaults[.launchAtLogin]
        launchAtLoginMenuItem.title = "Start at Login"
        launchAtLoginMenuItem.state = !launchAtLogin ? .on : .off
        LaunchAtLogin.isEnabled = !launchAtLogin
        defaults[.launchAtLogin] = !launchAtLogin
        if !launchAtLogin {
            showNotification(title: "DWA-140 Shortcut", withText: "This application now opens as soon as you login. 😀")
        }
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
        applicationMenu.addItem(NSMenuItem(title: "DWA-140 Shortcut", action: #selector(openSourcePage), keyEquivalent: ""))
        launchAtLoginMenuItem = NSMenuItem(title: "Start at Login", action: #selector(self.toggleLaunchAtLogin), keyEquivalent: "")
        launchAtLoginMenuItem.state = defaults[.launchAtLogin] ? .on : .off
        applicationMenu.addItem(launchAtLoginMenuItem)
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
    
    func setStatusIcon(icon: String) {
        if let button = statusItem.button {
            if button.image?.name() != icon {
                button.image = NSImage(named: NSImage.Name(icon))
            }
        }
    }
