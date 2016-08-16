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
    
    @IBOutlet weak var horizontalPopover: NSButton!
    
    @IBOutlet weak var brightnessDown: NSTextField!
    @IBOutlet weak var brightnessUp: NSTextField!
    @IBOutlet weak var contrastDown: NSTextField!
    @IBOutlet weak var contrastUp: NSTextField!
    @IBOutlet weak var volumeDown: NSTextField!
    @IBOutlet weak var volumeUp: NSTextField!
    
    @IBOutlet weak var disableHotkeys: NSButton!
    @IBOutlet weak var showPopoverOnHotkey: NSButton!
    @IBOutlet weak var updateOnOpening: NSButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if appDelegate.userPreferences.boolForKey("horizontalOrientation") { horizontalPopover.state = 1 }
        if appDelegate.userPreferences.boolForKey("disableHotKeys") { disableHotkeys.state = 1 }
        if appDelegate.userPreferences.boolForKey("showPopoverOnHotkey") { showPopoverOnHotkey.state = 1 }
        if appDelegate.userPreferences.boolForKey("updateOnOpening") { updateOnOpening.state = 1 }
        
        NSEvent.addLocalMonitorForEventsMatchingMask(NSEventMask.KeyDownMask, handler: {(evt: NSEvent!) -> NSEvent? in let key :UInt16 = evt.keyCode;
            self.lastKeyASCII = Int(key)
            self.lastKey = String(UnicodeScalar(key))
            return evt;
        });
        
        self.updateViewConstraints()
    }
    
    @IBAction func horizontalPopoverTicked(sender: NSButton) {
        print(sender.state)
        print(NSBundle.mainBundle().bundleURL.URLByDeletingLastPathComponent!.path!)
        if sender.state == 0 { appDelegate.userPreferences.setBool(false, forKey: "horizontalOrientation") }
        if sender.state == 1 { appDelegate.userPreferences.setBool(true, forKey: "horizontalOrientation") }
    }
    
    //
    
    @IBAction func brighnessDownKeyEntered(sender: NSTextField) {
//        print(lastKeyASCII)
//        print(lastKey)
//        sender.stringValue = lastKey
//        appDelegate.userPreferences.setInteger(lastKeyASCII, forKey: "brightnessDownKey")
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
    
    //
    
    @IBAction func disableHotkeysTicked(sender: NSButton) {
        if sender.state == 0 { appDelegate.userPreferences.setBool(false, forKey: "disableHotKeys") }
        else if sender.state == 1 { appDelegate.userPreferences.setBool(true, forKey: "disableHotKeys") }
    }
    
    @IBAction func showPopoverOnHotkeyTicked(sender: NSButton) {
        if sender.state == 0 { appDelegate.userPreferences.setBool(false, forKey: "showPopoverOnHotkey") }
        else if sender.state == 1 { appDelegate.userPreferences.setBool(true, forKey: "showPopoverOnHotkey") }
    }
    
    @IBAction func updateOnOpeningTicked(sender: AnyObject) {
        if sender.state == 0 { appDelegate.userPreferences.setBool(false, forKey: "updateOnOpening") }
        else if sender.state == 1 { appDelegate.userPreferences.setBool(true, forKey: "updateOnOpening") }
    }
    
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
