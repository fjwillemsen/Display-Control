//
//  preferencesViewController.swift
//  MenuBarApp
//
//  Created by Floris-Jan Willemsen on 24-05-16.
//  Copyright © 2016 Floris-Jan Willemsen. All rights reserved.
//

import Cocoa
import Foundation

class preferencesViewController: NSViewController {
    
    let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
    var lastKey = ""
    var lastKeyASCII = 0
    
    //UI Outlets
    @IBOutlet weak var brightnessDown: NSTextField!
    @IBOutlet weak var brightnessUp: NSTextField!
    @IBOutlet weak var contrastDown: NSTextField!
    @IBOutlet weak var contrastUp: NSTextField!
    @IBOutlet weak var volumeDown: NSTextField!
    @IBOutlet weak var volumeUp: NSTextField!
    
    
    @IBOutlet weak var verticalPopover: NSButton!
    @IBOutlet weak var horizontalPopover: NSButton!
    @IBOutlet weak var disableHotkeys: NSButton!
    @IBOutlet weak var showPopoverOnHotkey: NSButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if appDelegate.userPreferences.boolForKey("horizontalOrientation") { horizontalPopover.state = 1 }
        if appDelegate.userPreferences.boolForKey("disableHotKeys") { disableHotkeys.state = 1 }
        if appDelegate.userPreferences.boolForKey("showPopoverOnHotkey") { showPopoverOnHotkey.state = 1 }
        
        NSEvent.addLocalMonitorForEventsMatchingMask(NSEventMask.KeyDownMask, handler: {(evt: NSEvent!) -> NSEvent? in let key :UInt16 = evt.keyCode;
            self.lastKeyASCII = Int(key)
            self.lastKey = String(UnicodeScalar(key))
            return evt;
        });
        
        self.updateViewConstraints()
    }
    
    //UI Actions - Hotkey bindings
    @IBAction func brighnessDownKeyEntered(sender: NSTextField) {
    }
    
    @IBAction func brightnessUpKeyEntered(sender: NSTextField) {
    }
    
    @IBAction func contrastDownKeyEntered(sender: NSTextField) {
    }
    
    @IBAction func contrastUpKeyEntered(sender: NSTextField) {
    }
    
    @IBAction func volumeDownKeyEntered(sender: NSTextField) {
    }
    
    @IBAction func volumeUpKeyEntered(sender: NSTextField) {
    }

    
    //UI Actions - Booleans
    @IBAction func verticalPopoverTicked(sender: NSButton) {
        horizontalPopover.state = 0
        appDelegate.userPreferences.setBool(false, forKey: "horizontalOrientation")
    }
    
    @IBAction func horizontalPopoverTicked(sender: NSButton) {
        verticalPopover.state = 0
        appDelegate.userPreferences.setBool(true, forKey: "horizontalOrientation")
    }
    
    @IBAction func verticalPopoverImageTicked(sender: NSButton) {
        verticalPopover.state = 1
        horizontalPopover.state = 0
        appDelegate.userPreferences.setBool(false, forKey: "horizontalOrientation")
    }
    
    @IBAction func horizontalPopoverImageTicked(sender: NSButton) {
        verticalPopover.state = 0
        horizontalPopover.state = 1
        appDelegate.userPreferences.setBool(true, forKey: "horizontalOrientation")
    }
    
    @IBAction func disableHotkeysTicked(sender: NSButton) {
        if sender.state == 0 { appDelegate.userPreferences.setBool(false, forKey: "disableHotKeys") }
        else if sender.state == 1 { appDelegate.userPreferences.setBool(true, forKey: "disableHotKeys") }
    }
    
    @IBAction func showPopoverOnHotkeyTicked(sender: NSButton) {
        if sender.state == 0 { appDelegate.userPreferences.setBool(false, forKey: "showPopoverOnHotkey") }
        else if sender.state == 1 { appDelegate.userPreferences.setBool(true, forKey: "showPopoverOnHotkey") }
    }
    
    
    //UI Actions - Buttons
    @IBAction func quitButtonPressed(sender: NSButton) {
        exit(0)
    }
    
    @IBAction func applyButtonPressed(sender: NSButton) {
        let path = NSBundle.mainBundle().bundleURL.URLByDeletingLastPathComponent!.path! + "/Display Control.app"
        let task = NSTask()
        task.launchPath = "/usr/bin/open"
        task.arguments = [path]
        task.launch()
        exit(0)
    }
}
