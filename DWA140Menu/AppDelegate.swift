//
//  AppDelegate.swift
//  DWA140Menu
//
//  Created by Dylan Bolger on 9/3/18.
//  Copyright © 2018 Dylan Bolger. All rights reserved.
//

import Cocoa
import Foundation
struct Networking {
    
    enum NetworkInterfaceType: String, CustomStringConvertible {
        case Ethernet = "en2"
        case Unknown = ""
        var description: String {
            switch self {
            case .Ethernet:
                return "Ethernet"
            case .Unknown:
                return "Unknown"
            }
        }
    }
    static var networkInterfaceType: NetworkInterfaceType {
        if let name = Networking().getInterfaces().first?.name, let type = NetworkInterfaceType(rawValue: name) {
            return type
        }
        return .Unknown
    }
    static var isConnectedByEthernet: Bool {
        let networking = Networking()
        for addr in networking.getInterfaces() {
            if addr.name == NetworkInterfaceType.Ethernet.rawValue {
                return true
            }
        }
        return false
    }
    
    func getInterfaces() -> [(name : String, addr: String, mac : String)] {
        var addresses = [(name : String, addr: String, mac : String)]()
        var nameToMac = [ String: String ]()
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return [] }
        guard let firstAddr = ifaddr else { return [] }
        // For each interface ...
        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ptr.pointee.ifa_flags)
            if var addr = ptr.pointee.ifa_addr {
                let name = String(cString: ptr.pointee.ifa_name)
                // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                    switch Int32(addr.pointee.sa_family) {
                    case AF_LINK:
                        nameToMac[name] = withUnsafePointer(to: &addr) { unsafeAddr in
                            unsafeAddr.withMemoryRebound(to: sockaddr_dl.self, capacity: 1) { dl in
                                dl.withMemoryRebound(to: Int8.self, capacity: 1) { dll in
                                    let lladdr = UnsafeRawBufferPointer(start: dll + 8 + Int(dl.pointee.sdl_nlen), count: Int(dl.pointee.sdl_alen))
                                    if lladdr.count == 6 {
                                        return lladdr.map { String(format:"%02hhx", $0)}.joined(separator: ":")
                                    } else {
                                        return nil
                                    }
                                }
                            }
                        }
                    case AF_INET, AF_INET6:
                        // Convert interface address to a human readable string:
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if (getnameinfo(addr, socklen_t(addr.pointee.sa_len),
                                        &hostname, socklen_t(hostname.count),
                                        nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                            let address = String(cString: hostname)
                            addresses.append( (name: name, addr: address, mac : "") )
                        }
                    default:
                        break
                    }
                }
            }
        }
        freeifaddrs(ifaddr)
        // Now add the mac address to the tuples:
        for (i, addr) in addresses.enumerated() {
            if let mac = nameToMac[addr.name] {
                addresses[i] = (name: addr.name, addr: addr.addr, mac : mac)
            }
        }
        return addresses
    }
}
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    @objc func changeIcon() {
        if let button = statusItem.button {
            if Networking.isConnectedByEthernet {
                button.image = NSImage(named: "WifiConnected")
            } else {
                button.image = NSImage(named: "WifiError")
            }
        }
    }
    @objc func openCredits() {
        NSWorkspace.shared.open((URL(string:"https://github.com/fivepixels/dwa140shortcut") ?? nil)!)
    }
    @objc func ethStatus() -> String {
        if Networking.isConnectedByEthernet {
            return "USB WiFi is connected."
        } else {
            return "USB WiFi is disconnected."
        }
    }
    @objc func refreshStatus() {
        //recreate a new instance of the application
        let url = URL(fileURLWithPath: Bundle.main.resourcePath!)
        let path = url.deletingLastPathComponent().deletingLastPathComponent().absoluteString
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [path]
        task.launch()
        exit(0)
    }
    @objc func openDWA() {
        let fileman = FileManager.default
        let alluserspath = "/Library/PreferencePanes/DWA-140WirelessUtility.prefPane"
        let currentuserpath = "~/Library/PreferencePanes/DWA-140WirelessUtility.prefPane"
        if fileman.fileExists(atPath: alluserspath) {
            NSWorkspace.shared.open(URL(fileURLWithPath: alluserspath)) }
        else {
            NSWorkspace.shared.open(URL(fileURLWithPath: currentuserpath))
        }
    }
    @objc func openNetwork() {
        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/PreferencePanes/Network.prefPane"))
    }
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        changeIcon()
        constructMenu()
        }
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    func constructMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "DWA-140 Shortcut (GitHub)", action: #selector(openCredits), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: ethStatus(), action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Refresh Status", action: #selector(refreshStatus), keyEquivalent: "r"))
        menu.addItem(NSMenuItem(title: "Open DWA-140" , action: #selector(openDWA), keyEquivalent: "t1"))
        menu.addItem(NSMenuItem(title: "Network Preferences" , action: #selector(openNetwork), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))
        statusItem.menu = menu
    }
}
