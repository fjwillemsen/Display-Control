//
//  AppDelegate.swift
//  MenuBarApp
//
//  Created by Floris-Jan Willemsen on 19-05-16.
//  Copyright © 2016 Floris-Jan Willemsen. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
    let popover = NSPopover()
    var counter = 0
    var valueToRefresh = "all"
    let userPreferences = NSUserDefaults.standardUserDefaults()

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
//        dependencyInstaller().dependenciesInstalled() //checks if the required dependencies are installed (DDCCTL)
        
        if let button = statusItem.button {
            let icon = NSImage(named: "menuBarIcon")
            icon?.template = true
            button.image = icon
            button.action = #selector(AppDelegate.togglePopover(_:))
        }
    
        
        if userPreferences.boolForKey("horizontalOrientation") {
            popover.contentViewController = displayViewController(nibName: "displayViewController", bundle: nil)
        } else {
            popover.contentViewController = displayViewControllerVertical(nibName: "displayViewControllerVertical", bundle: nil)
        }
    
//        if userPreferences.integerForKey("displayNumber") == 0 { userPreferences.setInteger(1, forKey: "displayNumber") }
        userPreferences.setInteger(1, forKey: "displayNumber")
        
        acquirePrivileges()
        NSEvent.addGlobalMonitorForEventsMatchingMask(NSEventMask.LeftMouseUpMask, handler: closePopover)
        NSEvent.addGlobalMonitorForEventsMatchingMask(NSEventMask.RightMouseUpMask, handler: closePopover)
        
        if userPreferences.integerForKey("brighnessDownKey") == 0 { userPreferences.setInteger(122, forKey: "brighnessDownKey") }
        if userPreferences.integerForKey("brighnessUpKey") == 0 { userPreferences.setInteger(120, forKey: "brighnessUpKey") }
        if userPreferences.integerForKey("volumeDownKey") == 0 { userPreferences.setInteger(96, forKey: "volumeDownKey") }
        if userPreferences.integerForKey("volumeUpKey") == 0 { userPreferences.setInteger(97, forKey: "volumeUpKey") }
        
        if !userPreferences.boolForKey("disableHotKeys") {
            NSEvent.addGlobalMonitorForEventsMatchingMask(NSEventMask.KeyDownMask, handler: {(evt: NSEvent!) -> Void in let key :UInt16 = evt.keyCode;
                if Int(key) == self.userPreferences.integerForKey("brighnessDownKey") { self.changeStatus("-b", modifier: "10-"); } //F1, brightness down
                if Int(key) == self.userPreferences.integerForKey("brighnessUpKey") { self.changeStatus("-b", modifier: "10+"); } //F2, brightness up
                if Int(key) == self.userPreferences.integerForKey("volumeDownKey") { self.changeStatus("-v", modifier: "10-"); }; //F5, volume down
                if Int(key) == self.userPreferences.integerForKey("volumeUpKey") { self.changeStatus("-v", modifier: "10+"); } //F6, volume up
            });
        }
    }
    
    func acquirePrivileges() -> Bool {
        let accessEnabled = AXIsProcessTrustedWithOptions(
            [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true])
        
        if accessEnabled != true {
            let acquirePrivilegesAlert : NSAlert = NSAlert()
            acquirePrivilegesAlert.messageText = "Don't worry..."
            acquirePrivilegesAlert.informativeText = "You'll be asked by your system to give Monitor Control privileges. We require it for you to take advantage of all its functionalities, like hotkeys. Thanks in advance!"
            acquirePrivilegesAlert.alertStyle = NSAlertStyle.WarningAlertStyle
            acquirePrivilegesAlert.runModal()
            print("This app requires additional privileges in order for it to fully function. Please allow it to.")
        }
        return accessEnabled == true
    }
    
    func showPopover(sender: AnyObject?) {
        if let button = statusItem.button {
            popover.showRelativeToRect(button.bounds, ofView: button, preferredEdge: NSRectEdge.MinY)
        }
    }
    
    func closePopover(sender: AnyObject?) {
        popover.performClose(sender)
    }
    
    func togglePopover(sender: AnyObject?) {
        if popover.shown {
            closePopover(sender)
        } else {
            showPopover(sender)
            if userPreferences.boolForKey("updateOnOpening") {
                self.popover.contentViewController?.viewWillAppear()
            }
        }
    }
    
    func stringFromSubstring(string: String, leftString: String, rightString: String) -> String {
        var substring = ""
        if leftString != "null" {
            if let leftBounds = string.rangeOfString(leftString)?.endIndex {
                substring = string.substringFromIndex(leftBounds)
            }
        }
        if rightString != "null" {
            if let rightBounds = substring.rangeOfString(rightString)?.startIndex {
                substring = substring.substringToIndex(rightBounds)
            }
        }
        return substring
    }
    
    func getStatus(type: String, line: Int, display: Int, leftString: String, rightString: String) -> String {
        let task = NSTask()
        let outpipe = NSPipe()
        task.launchPath = "/usr/local/bin/ddcctl"
        task.standardError = outpipe
        var output : [String] = []
        task.arguments = ["-c", "-d", String(display), type, "?"]
        task.launch()
        
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String.fromCString(UnsafePointer(outdata.bytes)) {
            string = string.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
            output = string.componentsSeparatedByString("\n")
        }
        task.waitUntilExit()
        var substring = ""
        if output.count > line {
            substring = stringFromSubstring(output[line], leftString: leftString, rightString: rightString)
        } else { substring = "error" }
        while substring == "error" {
            counter += 1
//            print(counter, " ", type) //counts the number of times an error was subsequently received
            substring = getStatus(type, line: line, display: display, leftString: leftString, rightString: rightString)
            if counter > output.count {
                return "error"
            }
        }
        counter = 0
        print("Substring: ", substring)
        return substring
    }
    
    func getNumberOfDisplays() -> Int {
        var loopcounter = 0
        var displays = 0
        while displays == 0 {
            let string = getStatus("", line: loopcounter, display: 0, leftString: "I: found ", rightString: " displays")
            if string != "error" {
                let alias = Int(string)
                if alias != nil && alias != 0 { displays = alias! }
                loopcounter += 1
            }
        }
        return displays
    }
    
    func setStatus(type: String, setter: Int) {
        let task = NSTask()
        task.launchPath = "/usr/local/bin/ddcctl"
        task.arguments = ["-c", "-d", String(userPreferences.integerForKey("displayNumber")), type, String(setter)]
        task.launch()
        task.waitUntilExit()
    }
    
    func changeStatus(type: String, modifier: String) {
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
//            self.valueToRefresh = type
//            self.popover.contentViewController?.didChangeValueForKey(modifier)
//            self.valueToRefresh = "all"
            
            let task = NSTask()
            task.launchPath = "/usr/local/bin/ddcctl"
            print("DisplayNumber in changeStatus ", self.userPreferences.integerForKey("displayNumber"))
            task.arguments = ["-c", "-d", String(self.userPreferences.integerForKey("displayNumber")), type, modifier]
            task.launch()
            task.waitUntilExit()
            dispatch_async(dispatch_get_main_queue()) {
                self.valueToRefresh = type
//                self.popover.contentViewController?.viewDidLoad()
//                self.popover.contentViewController?.objectDidEndEditing(modifier)
                self.popover.contentViewController?.didChangeValueForKey(type + " " + modifier)
                self.valueToRefresh = "all"
            }
        }
        
        if userPreferences.boolForKey("showPopoverOnHotkey") { showPopover(statusItem.button) }
    }
    
    func refreshValues(type: String, modifier: String) {
        
        switch type {
        case "all", "-b":
            popover.contentViewController
        case "all", "-c":
            contrastSlider.integerValue = contrastSlider.integerValue + modifier
        case "all", "-v":
            volumeSlider.integerValue = volumeSlider.integerValue + modifier
        default:
            print("No Case, type: ", type, " modifier: ", modifier)
        }
        
    }
}

