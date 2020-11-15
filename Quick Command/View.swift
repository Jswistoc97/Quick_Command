/*
 * View.swift
 * Created by Joseph Swistock on 11/11/20
 *
 * Contains View class, which is the main View
 */

import Cocoa

/*
 * Subclass for main View
 * Makes subviews build from the top down, not from the bottom up
 * Adjusts to dark/light theme
 */
class View: NSView {
    
    var viewController: ViewController?     /* Main View controller for the app */
    var _isFlipped: Bool = true             /* isFlipped means that it is ordered from the top down */
    
    /*
     * Code that switches how subviews are presented
     */
    override var isFlipped: Bool{
        get{
            return _isFlipped
        }
        set{
            self._isFlipped = newValue
        }
    }
    
    /*
     * This is called when the user changes theme
     */
    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        
        /* Sanity check */
        if (viewController != nil){
            
            /* Change theme for app */
            viewController!.theme_change()
        }
    }
}
