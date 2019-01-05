//
//  ViewController.swift
//  DWA140Menu
//
//  Copyright © 2018 Dylan Bolger. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var versionLabel: NSTextField!
    @IBOutlet weak var loginButton: NSButton!
    @IBOutlet weak var awesomeSubtitle: NSTextField!
    @IBOutlet weak var loginSubtitle: NSTextField!
    
    let defaults : UserDefaults = .standard
    let delegate = NSApplication.shared.delegate as! AppDelegate
    var loginLaunch = UserDefaults.standard.bool(forKey: "loginLaunch")
    
    override func viewDidAppear() {
        loginButton.state = loginLaunch ? .on : .off
        versionLabel.stringValue = "Version " + (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String)!
        if loginLaunch {
            loginSubtitle.stringValue = "This application will launch when you login."
        }
    }
    
    func toggleLoginLaunch() {
        loginButton.state = !loginLaunch ? .on : .off
        defaults.set(!loginLaunch, forKey: "loginLaunch")
        loginLaunch = !loginLaunch
    }
    
    @IBAction func loginButtonPressed(_ sender: NSButton) {
        toggleLoginLaunch()
        if loginLaunch {
            loginSubtitle.stringValue = "This application will launch when you login."
        } else {
            loginSubtitle.stringValue = "An even easier way to get connected, faster."
        }
    }
    @IBAction func triedAwesome(_ sender: NSButton) {
        // it's an invisible button on top of the disabled checkbox.
        awesomeSubtitle.stringValue = "You can't change the fact that you're awesome."
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.awesomeSubtitle.stringValue = "It's just a fact."
        }
    }
    
    @IBAction func sourceButtonPressed(_ sender: NSButton) {
        NSWorkspace.shared.open((URL(string:"https://github.com/fivepixels/dwa140shortcut") ?? nil)!)
    }
    
    @IBAction func coffeePressed(_ sender: NSButton) {
        NSWorkspace.shared.open((URL(string: "https://paypal.me/fivepixels") ?? nil)!)
    }
    
    @IBAction func loveButtonPressed(_ sender: NSButton) {
        NSWorkspace.shared.open((URL(string:"https://twitter.com/o5pxels") ?? nil)!)
    }
}

