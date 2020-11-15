/*
 * ConfigEditWindow.swift
 * Created by Joseph Swistock on 11/12/20
 *
 * Contains ConfigEditWindow class, which subclasses NSWindow
 */

import Cocoa

/*
 * ConfigEditWindow is a subclass of NSWindow, the window for the config editor
 */
class ConfigEditWindow: NSWindow {
    
    /*
     * Override the closing function
     */
    override func close() {
        
        /* Get view controller for main window, NOT config editor window */
        let viewController = (contentViewController as! ConfigEditViewController).mainViewController
        
        /* Set main view controller's editing window to nil */
        viewController!.editWindow = nil
        
        super.close()
    }
}
