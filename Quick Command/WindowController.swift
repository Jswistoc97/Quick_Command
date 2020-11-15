/*
 * WindowController.swift
 * Created by Joseph Swistock on 11/12/20
 *
 * Contains WindowController class, the window controller for the main window
 */

import Cocoa

/*
 * WindowController is a subclass of NSWindowController
 * Implemented so the window position will be restored
 */
class WindowController: NSWindowController {

    /*
     * Called when the window is loaded
     */
    override func windowDidLoad() {
        super.windowDidLoad()
    
        /* Save window's */
        self.windowFrameAutosaveName = NSWindow.FrameAutosaveName("mainWindow")
    }

}
