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
    
    @IBAction func quitButtonPressed(sender: AnyObject) {
        exit(0)
    }

    @IBAction func preferencesButtonPressed(sender: AnyObject) {
        appDelegate.closePopover(appDelegate.statusItem)
        appDelegate.popover.contentViewController = preferencesViewController(nibName: "preferencesViewController", bundle: nil)
        appDelegate.showPopover(appDelegate.statusItem)
    }
    
    @IBAction func displayButtonPressed(sender: AnyObject) {
        //TODO: Make this button pop up the modelPicker
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
    }
    
    override func contrastSliderSetter(value: Int) {
        contrastSlider.integerValue = value
    }
    
    override func volumeSliderSetter(value: Int) {
        volumeSlider.integerValue = value
    }
    
    override func modelPickerSetter(value: NSPopUpButton) {
        modelPicker = value
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
    override func popUpButtonSelectTitle(value: String) {
        self.modelPicker.selectItemWithTitle(value)
    }
    
    override func popUpButtonSelectIndex(value: Int) {
        modelPicker.selectItemAtIndex(value)
    }
}
