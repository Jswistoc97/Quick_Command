/*
 * Window.swift
 * Created by Joseph Swistock on 11/12/20
 *
 * Contains Window class, which subclasses NSWindow
 */

import Cocoa

/*
 * Class subclass for main window to close editing window before closing current window
 */
class Window: NSWindow {
    
    /*
     * Override the closing function
     */
    override func close() {
        
        /* Close editing window if possible */
        if ((contentViewController as! ViewController).editWindow != nil){
            (contentViewController as! ViewController).editWindow!.close()
        }
        
        super.close()
    }
}
