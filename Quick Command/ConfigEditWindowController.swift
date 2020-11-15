/*
 * ConfigEditWindowController.swift
 * Created by Joseph Swistock on 11/12/20
 *
 * Contains ConfigEditWindowController class, the window controller for the config editor
 */

import Cocoa

/*
 * ConfigEditWindowController is a subclass of NSWindowController
 * Implemented so the app can generate the window
 */
class ConfigEditWindowController: NSWindowController {

    /*
     * Called when the window is loaded
     */
    override func windowDidLoad() {
        super.windowDidLoad()
    
        /* Save window's position */
        self.windowFrameAutosaveName = NSWindow.FrameAutosaveName("configWindow")
    }
    
    /*
     * Loads a new window
     */
    class func loadFromNib() -> ConfigEditWindowController {
        
        /* Load the window from Main.storyboard, with the id as 'ConfigEdit' */
        return NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "ConfigEdit") as! ConfigEditWindowController
    }

}
