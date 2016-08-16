//
//  displayViewControllerVertical.swift
//  MenuBarApp
//
//  Created by Floris-Jan Willemsen on 24-05-16.
//  Copyright © 2016 Floris-Jan Willemsen. All rights reserved.
//

import Cocoa

class displayViewControllerVertical: NSViewController {

    let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
    private var modifier = 0
    
    @IBOutlet weak var brightnessSlider: NSSlider!
    @IBOutlet weak var contrastSlider: NSSlider!
    @IBOutlet weak var volumeSlider: NSSlider!
    @IBOutlet weak var modelPicker: NSPopUpButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            self.refreshDisplayList()
            self.refreshValues()
        }
    }
    
    @IBAction func brightnessSliderChanged(sender: NSSlider) {
        appDelegate.setStatus("-b", setter: sender.integerValue)
    }
    
    @IBAction func contrastSliderChanged(sender: NSSlider) {
        appDelegate.setStatus("-c", setter: sender.integerValue)
    }
    
    @IBAction func volumeSliderChanged(sender: NSSlider) {
        appDelegate.setStatus("-v", setter: sender.integerValue)
    }
    
    @IBAction func quitButtonPressed(sender: AnyObject) {
        exit(0)
    }

    @IBAction func preferencesButtonPressed(sender: AnyObject) {
        appDelegate.popover.contentViewController = preferencesViewController(nibName: "preferencesViewController", bundle: nil)
    }
    
    @IBAction func displayButtonPressed(sender: AnyObject) {
        //TODO: Make this button pop up the modelPicker
    }
    
    @IBAction func displayPicked(sender: NSPopUpButton) {
        NSUserDefaults.standardUserDefaults().setInteger(modelPicker.indexOfSelectedItem+1, forKey: "displayNumber")
        refreshValues()
    }
    
    override func didChangeValueForKey(key: String) {
        if key == "10-" {
            modifier = -10
        } else if key == "10+" {
            modifier = 10
        }
        refreshValues()
    }
    
    func brightnessSliderSetter(value: Int) {
        brightnessSlider.integerValue = value
    }
    
    func contrastSliderSetter(value: Int) {
        contrastSlider.integerValue = value
    }
    
    func volumeSliderSetter(value: Int) {
        volumeSlider.integerValue = value
    }
    
    func brightnessSliderModifier(value: Int) {
        brightnessSlider.integerValue = brightnessSlider.integerValue + value
    }
    
    func contrastSliderModifier(value: Int) {
        contrastSlider.integerValue = contrastSlider.integerValue + value
    }
    
    func volumeSliderModifier(value: Int) {
        volumeSlider.integerValue = volumeSlider.integerValue + value
    }
    
    func refreshDisplayList() {
        modelPicker.removeAllItems()
        for i in 0 ..< appDelegate.getNumberOfDisplays() {
            modelPicker.addItemWithTitle(appDelegate.getStatus("", line: 2+appDelegate.getNumberOfDisplays(), display: i+1, leftString: "got edid.name: ", rightString: "null"))
        }
        print("Detected Displays: ", modelPicker.itemTitles)
        modelPicker.selectItemAtIndex(0)
    }
    
    func refreshValues() {
        print("Value to refresh: " + appDelegate.valueToRefresh)
        let displayNumber = NSUserDefaults.standardUserDefaults().integerForKey("displayNumber");
        print("Display Number Pref: ", displayNumber)
        if appDelegate.valueToRefresh == "all" || appDelegate.valueToRefresh == "-n" {
            let modelName = appDelegate.getStatus("", line: 2+appDelegate.getNumberOfDisplays(), display: displayNumber, leftString: "got edid.name: ", rightString: "null")
            print("Display: ", modelName, " number ", displayNumber)
            if modelName == "Color LCD" {
                let noDisplayAlert : NSAlert = NSAlert()
                if displayNumber < appDelegate.getNumberOfDisplays() {
                    NSUserDefaults.standardUserDefaults().setInteger(displayNumber+1, forKey: "displayNumber")
                    noDisplayAlert.messageText = "Oops, that won't work..."
                    noDisplayAlert.informativeText = "Your built-in screen was set as the preffered display. Display Control is meant for non-Apple displays. Don't worry, we've set the prefference to a non-Apple display."
                    noDisplayAlert.alertStyle = NSAlertStyle.WarningAlertStyle
                    noDisplayAlert.runModal()
                    refreshValues()
                    return
                }
                else {
                    noDisplayAlert.messageText = "We couldn't find a monitor..."
                    noDisplayAlert.informativeText = "No external display has been connected. Connect a display and try again. Display Control will now exit."
                    noDisplayAlert.alertStyle = NSAlertStyle.WarningAlertStyle
                    noDisplayAlert.runModal()
                    exit(0)
                }
            } else if modelName != "error" {
                modelPicker.selectItemWithTitle(modelName)
                print("modelName: ", modelName)
                print("Currently picked: ", modelPicker.titleOfSelectedItem)
            } else {
                modelPicker.selectItemAtIndex(0)
            }
        }
        
        if appDelegate.valueToRefresh == "all" || appDelegate.valueToRefresh == "-b" {
            if let newValue = Int(appDelegate.getStatus("-b", line: 7+appDelegate.getNumberOfDisplays(), display: displayNumber, leftString: "current: ", rightString: ", max:")) {
                brightnessSlider.integerValue = newValue
            }
        }
        if appDelegate.valueToRefresh == "all" || appDelegate.valueToRefresh == "-c" {
            if let newValue = Int(appDelegate.getStatus("-c", line: 7+appDelegate.getNumberOfDisplays(), display: displayNumber, leftString: "current: ", rightString: ", max:")) {
                contrastSlider.integerValue = newValue
            }
        }
        if appDelegate.valueToRefresh == "all" || appDelegate.valueToRefresh == "-v" {
            if let newValue = Int(appDelegate.getStatus("-v", line: 7+appDelegate.getNumberOfDisplays(), display: displayNumber, leftString: "current: ", rightString: ", max:")) {
                volumeSlider.integerValue = newValue
            }
        }
    }
}
