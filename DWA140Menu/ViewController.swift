//
//  ViewController.swift
//  DWA140Menu
//
//  Copyright © 2018 Dylan Bolger. All rights reserved.
//

import Cocoa
import LaunchAtLogin

class ViewController: NSViewController {
    
    @IBOutlet weak var versionLabel: NSTextField!
    @IBOutlet weak var loginButton: NSButton!
    @IBOutlet weak var awesomeSubtitle: NSTextField!
    @IBOutlet weak var loginSubtitle: NSTextField!
    @IBOutlet weak var versionCheckLabel: NSButton!
    
    let defaults : UserDefaults = .standard
    let delegate = NSApplication.shared.delegate as! AppDelegate
    var loginLaunch = UserDefaults.standard.bool(forKey: "loginLaunch")
    let appVersion = (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String)!
    let style = NSMutableParagraphStyle()
    
    
    override func viewDidAppear() {
        style.alignment = .right
        if checkForUpdate() == "Update available" {
            versionCheckLabel.stringValue = checkForUpdate()
            versionCheckLabel.attributedTitle = NSAttributedString(string: "Update available", attributes: [ NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), NSAttributedString.Key.paragraphStyle : style ])
        }
        loginButton.state = loginLaunch ? .on : .off
        versionLabel.stringValue = "Version " + appVersion
        if loginLaunch {
            loginSubtitle.stringValue = "This application will launch when you login."
        }
    }
    
    func toggleLoginLaunch() {
        loginButton.state = !loginLaunch ? .on : .off
        defaults.set(!loginLaunch, forKey: "loginLaunch")
        loginLaunch = !loginLaunch
        if loginLaunch {
            LaunchAtLogin.isEnabled = true
        } else {
            LaunchAtLogin.isEnabled = false
        }
    }
    
    func checkForUpdate() -> String  {
        var Update: String? = nil
        if let url = URL(string: "https://raw.githubusercontent.com/FivePixels/dwa140shortcut/master/version.txt") {
            Update = try? String(contentsOf: url, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        }
        let result = Update?.dropLast(1)
        if Update == nil {
            return "?"
        } else if result!.compare(appVersion, options: .numeric, range: nil, locale: .current) == .orderedDescending {
            return "Update available"
        } else {
            return "Up to date"
        }
    }
    
    @IBAction func updatePressed(_ sender: NSButton) {
        if checkForUpdate() == "Update available" {
            NSWorkspace.shared.open(URL(string: "https://github.com/fivepixels/dwa140shortcut/releases")!)
        }
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

