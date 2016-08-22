//
//  displayViewControllerExtender.swift
//  Display Control
//
//  Created by Floris-Jan Willemsen on 17-08-16.
//  Copyright © 2016 Floris-Jan Willemsen. All rights reserved.
//

import Cocoa

extension NSViewController {
    
    //Getters
    func brightnessSliderGetter()-> Int {
        return 0
    }
    
    func contrastSliderGetter()-> Int {
        return 0
    }
    
    func volumeSliderGetter()-> Int {
        return 0
    }
    
    func modelPickerGetter()-> NSPopUpButton {
        return NSPopUpButton()
    }
    
    //Setters
    func brightnessSliderSetter(value: Int) {
    }
    
    func contrastSliderSetter(value: Int) {
    }
    
    func volumeSliderSetter(value: Int) {
    }
    
    func modelPickerSetter(value: NSPopUpButton) {
    }
    
    //Modifiers
    func brightnessSliderModifier(value: Int) {
    }
    
    func contrastSliderModifier(value: Int) {
    }
    
    func volumeSliderModifier(value: Int) {
    }
    
    func modelPickerModifier(value: [String]) {
    }
    
    //Selectors
    func popUpButtonSelectTitle(value: String) {
    }

    func popUpButtonSelectIndex(value: Int) {
    }
}