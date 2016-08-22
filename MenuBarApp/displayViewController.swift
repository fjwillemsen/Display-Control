//
//  displayViewController.swift
//  MenuBarApp
//
//  Created by Floris-Jan Willemsen on 20-05-16.
//  Copyright © 2016 Floris-Jan Willemsen. All rights reserved.
//

import Cocoa

class displayViewController: NSViewController {
    
    let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
    
    //UI Outlets
    @IBOutlet weak var brightnessSlider: NSSlider!
    @IBOutlet weak var contrastSlider: NSSlider!
    @IBOutlet weak var volumeSlider: NSSlider!
    @IBOutlet weak var modelPicker: NSPopUpButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.showPopover(appDelegate.statusItem.button)
        appDelegate.closePopover(appDelegate.statusItem.button)
//        dispatch_async(dispatch_get_global_queue(priority, 0)) {
//            self.appDelegate.refreshValues("all")
//            print("Refreshed")
//        }
    }
    
    //UI Actions
    @IBAction func brightnessSliderChanged(sender: NSSlider) {
        appDelegate.setStatus("-b", setter: sender.integerValue)
    }
    
    @IBAction func contrastSliderChanged(sender: NSSlider) {
        appDelegate.setStatus("-c", setter: sender.integerValue)
    }
    
    @IBAction func volumeSliderChanged(sender: NSSlider) {
        appDelegate.setStatus("-v", setter: sender.integerValue)
    }
    
    @IBAction func quitButtonPressed(sender: NSButton) {
        exit(0)
    }
    
    @IBAction func preferencesButtonPressed(sender: NSButton) {
        appDelegate.closePopover(appDelegate.statusItem)
        appDelegate.popover.contentViewController = preferencesViewController(nibName: "preferencesViewController", bundle: nil)
        appDelegate.showPopover(appDelegate.statusItem)
    }
    
    @IBAction func displayPicked(sender: NSPopUpButton) {
        NSUserDefaults.standardUserDefaults().setInteger(modelPicker.indexOfSelectedItem+1, forKey: "displayNumber")
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            self.appDelegate.refreshValues("all")
        }
    }
    
    
    //Getters
    override func brightnessSliderGetter()-> Int {
        return brightnessSlider.integerValue
    }
    
    override func contrastSliderGetter()-> Int {
        return contrastSlider.integerValue
    }
    
    override func volumeSliderGetter()-> Int {
        return volumeSlider.integerValue
    }
    
    override func modelPickerGetter() -> NSPopUpButton {
        return modelPicker
    }
    
    
    //Setters
    override func brightnessSliderSetter(value: Int) {
        brightnessSlider.integerValue = value
        print("Brightness Slider set to ", value)
    }
    
    override func contrastSliderSetter(value: Int) {
        contrastSlider.integerValue = value
        print("Contrast Slider set to ", value)
    }
    
    override func volumeSliderSetter(value: Int) {
        volumeSlider.integerValue = value
        print("Volume Slider set to ", value)
    }
    
    override func modelPickerSetter(value: NSPopUpButton) {
        modelPicker = value
        print("ModelPicker Slider set to ", modelPicker.itemTitles)
    }
    
    
    //Modifiers
    override func brightnessSliderModifier(value: Int) {
        brightnessSlider.integerValue = brightnessSlider.integerValue + value
    }
    
    override func contrastSliderModifier(value: Int) {
        contrastSlider.integerValue = contrastSlider.integerValue + value
    }
    
    override func volumeSliderModifier(value: Int) {
        volumeSlider.integerValue = volumeSlider.integerValue + value
    }
    
    override func modelPickerModifier(value: [String]) {
        modelPicker.removeAllItems()
        modelPicker.addItemsWithTitles(value)
    }
    
    
    //Selectors
    override func popUpButtonSelectTitle(value: String) { //fatal error: unexpectedly found nil while unwrapping an Optional value
        print("Model picker ")
        print(modelPicker)
        self.modelPicker.selectItemWithTitle(value)
    }
    
    override func popUpButtonSelectIndex(value: Int) {
        modelPicker.selectItemAtIndex(value)
    }
    
    //    override func didChangeValueForKey(key: String) {
//        let type : String
//        if key == "-b 10-" {
//            modifier = -10
//            refreshValue = "-b"
//        } else if key == "-b 10+" {
//            modifier = 10
//            refreshValue = "-b"
//        } else if key == "-c 10-" {
//            modifier = -10
//            refreshValue = "-c"
//        } else if key == "-c 10+" {
//            modifier = 10
//            refreshValue = "-c"
//        }
//        
//        appDelegate.refreshValues()
//    }
    
//    func refreshDisplayList() {
//        dispatch_async(dispatch_get_global_queue(priority, 0)) { //Executed on background thread
//            let newModelPicker = NSPopUpButton()
//            newModelPicker.removeAllItems()
//            for i in 0 ..< getNumberOfDisplays() {
//                newModelPicker.addItemWithTitle(getStatus("", line: 2+getNumberOfDisplays(), display: i+1, leftString: "got edid.name: ", rightString: "null"))
//            }
//            dispatch_async(dispatch_get_main_queue()) {
//                self.modelPicker = newModelPicker
//                self.appDelegate.refreshValues("-n", modifier: "null")
//            }
//        }
//    }
    
//    func refreshValues() {
//        
//        switch self.refreshValue {
//        case "all", "-b":
//            brightnessSlider.integerValue = brightnessSlider.integerValue + modifier
//        case "all", "-c":
//            contrastSlider.integerValue = contrastSlider.integerValue + modifier
//        case "all", "-v":
//            volumeSlider.integerValue = volumeSlider.integerValue + modifier
//        default:
//            print("    NO CASE, refrehValue: ", self.refreshValue)
//        }
//        
//        var brightnessValue = 0
//        var contrastValue = 0
//        var volumeValue = 0
//        
//        print("Value to refresh: " + appDelegate.valueToRefresh)
//        dispatch_async(dispatch_get_global_queue(priority, 0)) { //Executed on background thread
//            let displayNumber = NSUserDefaults.standardUserDefaults().integerForKey("displayNumber")
//            print("Self Value to refresh: " + self.refreshValue)
//            if self.refreshValue == "all" || self.refreshValue == "-n" {
//                let modelName = self.appDelegate.getStatus("", line: 2+self.appDelegate.getNumberOfDisplays(), display: displayNumber, leftString: "got edid.name: ", rightString: "null")
//                if modelName == "Color LCD"{
//                    let noDisplayAlert : NSAlert = NSAlert()
//                    if displayNumber < self.appDelegate.getNumberOfDisplays() {
//                        NSUserDefaults.standardUserDefaults().setInteger(displayNumber+1, forKey: "displayNumber")
//                        noDisplayAlert.messageText = "Oops, that won't work..."
//                        noDisplayAlert.informativeText = "Your built-in screen was set as the preffered display. Monitor Control is meant for non-Apple displays. Don't worry, we've set the prefference to a non-Apple display."
//                        noDisplayAlert.alertStyle = NSAlertStyle.WarningAlertStyle
//                        noDisplayAlert.runModal()
//                        self.refreshValues()
//                        return
//                    }
//                    else {
//                        noDisplayAlert.messageText = "We couldn't find a monitor..."
//                        noDisplayAlert.informativeText = "No external display has been connected. Connect a display and try again. Monitor Control will now exit."
//                        noDisplayAlert.alertStyle = NSAlertStyle.WarningAlertStyle
//                        noDisplayAlert.runModal()
//                        exit(0)
//                    }
//                } else if modelName != "error" {
//                    self.modelPicker.selectItemWithTitle(modelName)
//                } else {
//                    self.modelPicker.selectItemAtIndex(0)
//                }
//            }
//            
//            if self.refreshValue == "all" || self.refreshValue == "-b" {
//                print("Brightness value: ", self.brightnessSlider.integerValue)
//                if let newValue = Int(self.appDelegate.getStatus("-b", line: 7+self.appDelegate.getNumberOfDisplays(), display: displayNumber, leftString: "current: ", rightString: ", max:")) {
//                    print("New Value: ", newValue)
//                    brightnessValue = newValue
//                }
//            }
//            if self.appDelegate.valueToRefresh == "all" || self.appDelegate.valueToRefresh == "-c" {
//                if let newValue = Int(self.appDelegate.getStatus("-c", line: 7+self.appDelegate.getNumberOfDisplays(), display: displayNumber, leftString: "current: ", rightString: ", max:")) {
//                    print("New Value: ", newValue)
//                    contrastValue = newValue
//                }
//            }
//            if self.refreshValue == "all" || self.refreshValue == "-v" {
//                if let newValue = Int(self.appDelegate.getStatus("-v", line: 7+self.appDelegate.getNumberOfDisplays(), display: displayNumber, leftString: "current: ", rightString: ", max:")) {
//                    print("New Value: ", newValue)
//                    volumeValue = newValue
//                }
//            }
//            
//            dispatch_async(dispatch_get_main_queue()) {
//                self.brightnessSlider.integerValue = brightnessValue
//                self.contrastSlider.integerValue = contrastValue
//                self.volumeSlider.integerValue = volumeValue
//            }
//            
//        }
//        
//    }
}
