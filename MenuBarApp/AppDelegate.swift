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
//    var valueToRefresh = "all"
    let userPreferences = NSUserDefaults.standardUserDefaults()
    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT

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
        
        //Preferences to be reset to value at startup:
        userPreferences.setInteger(1, forKey: "displayNumber")
        userPreferences.setBool(true, forKey: "updateOnOpening")
        
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
        
        self.popover.contentViewController?.viewDidLoad()
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            self.refreshValues("all")
        }
    }
    
    func acquirePrivileges() -> Bool {
        let accessEnabled = AXIsProcessTrustedWithOptions(
            [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true])
        
        if accessEnabled != true {
            let acquirePrivilegesAlert : NSAlert = NSAlert()
            acquirePrivilegesAlert.messageText = "Don't worry..."
            acquirePrivilegesAlert.informativeText = "You'll be asked by your system to give Monitor Control privileges. We require it for you to take advantage of all its functionalities, like hotkeys."
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
                dispatch_async(dispatch_get_global_queue(priority, 0)) {
                    self.refreshValues("all")
                }
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
//                self.valueToRefresh = type
//                self.popover.contentViewController?.viewDidLoad()
//                self.popover.contentViewController?.objectDidEndEditing(modifier)
//                self.popover.contentViewController?.didChangeValueForKey(type + " " + modifier)
                self.refreshValues(type, modifier: modifier)
//                self.valueToRefresh = "all"
            }
        }
        
        if userPreferences.boolForKey("showPopoverOnHotkey") { showPopover(statusItem.button) }
    }
    
    func refreshValues(type: String, modifier: String?=nil) {
        
        let displayNumber = NSUserDefaults.standardUserDefaults().integerForKey("displayNumber")
            
//        if type == "all" or type == "-d" {
//                print("ModelPicker RF: ", self.popover.contentViewController?.modelPickerGetter().itemTitles)
//                refreshValues("-d")
//                print("HW")
////                print("ModelPicker RF: ", self.popover.contentViewController?.modelPickerGetter().itemTitles)
//                refreshValues("-n")
//                print("BW")
////                print("ModelPicker RF: ", self.popover.contentViewController?.modelPickerGetter().itemTitles)
//                refreshValues("-b")
////                print("ModelPicker RF: ", self.popover.contentViewController?.modelPickerGetter().itemTitles)
//                refreshValues("-c")
////                print("ModelPicker RF: ", self.popover.contentViewController?.modelPickerGetter().itemTitles)
//                refreshValues("-v")
        
        if type == "all" || type == "-d" { //Refreshes the display list
//            let newModelPicker = NSPopUpButton()
            var stringArray = [String]()
//            newModelPicker.removeAllItems()
            for i in 0 ..< getNumberOfDisplays() {
                stringArray.append(getStatus("", line: 2+getNumberOfDisplays(), display: i+1, leftString: "got edid.name: ", rightString: "null"))
//                newModelPicker.addItemWithTitle(getStatus("", line: 2+getNumberOfDisplays(), display: i+1, leftString: "got edid.name: ", rightString: "null"))
            }
            self.popover.contentViewController?.modelPickerModifier(stringArray)
//            newModelPicker.addItemWithTitle("Hello world")
//            print("ModelPicker ", self.popover.contentViewController?.modelPickerGetter())
//            self.popover.contentViewController?.modelPickerSetter(newModelPicker)
//            print("ModelPicker ", self.popover.contentViewController?.modelPickerGetter())
//            print("CVC ", self.popover.contentViewController)
//            refreshValues("-n")
        }

        if type == "all" || type == "-n" { //Refreshes the display name
            print("ModelPicker -N")
            print(self.popover.contentViewController?.modelPickerGetter())
            let modelName = getStatus("", line: 2+getNumberOfDisplays(), display: displayNumber, leftString: "got edid.name: ", rightString: "null")
            if modelName == "Color LCD"{
                let noDisplayAlert : NSAlert = NSAlert()
                if displayNumber < getNumberOfDisplays() {
                    NSUserDefaults.standardUserDefaults().setInteger(displayNumber+1, forKey: "displayNumber")
                    noDisplayAlert.messageText = "Oops, that won't work..."
                    noDisplayAlert.informativeText = "Your built-in screen was set as the preffered display. Monitor Control is meant for non-Apple displays. Don't worry, we've set the prefference to a non-Apple display."
                    noDisplayAlert.alertStyle = NSAlertStyle.WarningAlertStyle
                    noDisplayAlert.runModal()
                    self.refreshValues(type, modifier: "all")
                    return
                }
                else {
                    noDisplayAlert.messageText = "We couldn't find a monitor..."
                    noDisplayAlert.informativeText = "No external display has been connected. Connect a display and try again. Monitor Control will now exit."
                    noDisplayAlert.alertStyle = NSAlertStyle.WarningAlertStyle
                    noDisplayAlert.runModal()
                    exit(0)
                }
            } else if modelName != "error" {
                self.popover.contentViewController?.popUpButtonSelectTitle(modelName)
            } else {
                self.popover.contentViewController?.popUpButtonSelectIndex(0)
            }
        }
        
        if type == "all" || type == "-b" { //Refreshes the brightness value
            if let newValue = Int(getStatus("-b", line: 7+getNumberOfDisplays(), display: displayNumber, leftString: "current: ", rightString: ", max:")) {
                print("New Value: ", newValue)
                self.popover.contentViewController?.brightnessSliderSetter(newValue)
            }
        }
        
        if type == "all" || type == "-c"{ //Refreshes the contrast value
            if let newValue = Int(getStatus("-c", line: 7+getNumberOfDisplays(), display: displayNumber, leftString: "current: ", rightString: ", max:")) {
                print("New Value: ", newValue)
                self.popover.contentViewController?.contrastSliderSetter(newValue)
            }
        }
        
        if type == "all" || type == "-v" { //Refreshes the volume value
            if let newValue = Int(getStatus("-v", line: 7+getNumberOfDisplays(), display: displayNumber, leftString: "current: ", rightString: ", max:")) {
                print("New Value: ", newValue)
                self.popover.contentViewController?.volumeSliderSetter(newValue)
            }
        }
        
    }
}

