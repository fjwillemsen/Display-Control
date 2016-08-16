//
//  dependencyInstaller.swift
//  MenuBarApp
//
//  Created by Floris-Jan Willemsen on 09-06-16.
//  Copyright © 2016 Floris-Jan Willemsen. All rights reserved.
//

import Cocoa

class dependencyInstaller {
    
    let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
    
    func dependenciesInstalled() {
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath("/usr/local/bin/ddcctl") {
            return
        } else {
            let noDDCCTLAlert : NSAlert = NSAlert()
            noDDCCTLAlert.messageText = "Monitor Control requires DDCCTL"
            noDDCCTLAlert.informativeText = "It appears DDCCTL hasn't been installed. Would you like to have it installed? Be aware: canceling this will exit Monitor Control."
            noDDCCTLAlert.alertStyle = NSAlertStyle.WarningAlertStyle
            noDDCCTLAlert.addButtonWithTitle("OK")
            noDDCCTLAlert.addButtonWithTitle("Cancel")
            let response = noDDCCTLAlert.runModal()
            if response == NSAlertFirstButtonReturn {
                print("OK")
                installDependencies()
            }
            else { exit(0) }
        }
    }
    
    func executeCommand(launchPath: String?, program: String?, directory: String?, arguments: [String]) {
        let task = NSTask()
        if launchPath != nil && program != nil { task.launchPath = launchPath! + program! }
        else if program != nil { task.launchPath = "/usr/bin/" + program! }
        if (directory != nil) { task.currentDirectoryPath = directory! }
    
        task.arguments = arguments
        task.launch()
        task.waitUntilExit()
    }
    
    func installDependencies() {
        executeCommand(nil, program: "curl", directory: "~/Desktop", arguments: ["-LOk", "https://github.com/kfix/ddcctl/archive/master.zip"])
        executeCommand(nil, program: "unzip", directory: "~/Desktop", arguments: ["master.zip"])
        executeCommand(nil, program: "osascript", directory: nil, arguments: ["-e", "do shell script \"mkdir -p /usr/local/bin/; cd ~/Desktop/ddcctl-master; make install\" with administrator privileges"])
//        executeCommand(nil, program: "make", directory: "~/Desktop/ddcctl-master", arguments: ["install"])
        executeCommand("/bin/", program: "rm", directory: "~/Desktop", arguments: ["-f", "master.zip"])
        executeCommand("/bin/", program: "rm", directory: "~/Desktop", arguments: ["-rf", "ddcctl-master"])
    }
}
