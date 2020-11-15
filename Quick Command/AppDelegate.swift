/*
 * AppDelegate.swift
 * Created by Joseph Swistock on 11/10/20
 *
 * Contains AppDelegate class, which operates as the application's 'main'
 * AppDelegate controls certain app properties
 */

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    /* Variables */
    var viewController: ViewController?     /* Main view controller for app */

    /*
     * Called when the app is done launching, unused
     */
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        /* Setup is handled by ViewController */
    }

    /*
     * Called when app is terminating
     */
    func applicationWillTerminate(_ aNotification: Notification) {
        
        /* Call teradown function for C code */
        exec_teardown()
    }
    
    /*
     * Creates additional menu for dock menu
     */
    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        
        /* Initilize menu */
        let menu = NSMenu(title: "")
        
        /* Add item with the ability to quit and kill all processes */
        menu.addItem(NSMenuItem(title: "Quit and Kill All Processes", action: #selector(quitAndKillAllDock), keyEquivalent: ""))
        
        return menu
    }
    
    /*
     * Dislays information about the Quick Command
     */
    @IBAction func aboutEvent(_ sender: Any) {
        ViewController.warning_alert(title: "Quick Command", message: "Version 1.0\nDeveloped by Joseph Swistock")
    }
    
    /*
     * Kills all processes, for toolbar menu
     */
    @IBAction func killAllProcesses(_ sender: Any) {
        kill_all_processes()
    }
    @IBAction func quitAndKillAllProcesses(_ sender: Any) {
        exec_teardown_and_kill()
    }
    
    /*
     * Loads and displays config editor
     */
    @IBAction func configEdit(_ sender: Any) {
        
        /* If there's already an editing window up */
        if (viewController!.editWindow != nil){
            
            /* Make the editing window key */
            viewController!.editWindow!.makeKeyAndOrderFront(self)
            
            /* Return from function */
            return
        }
        
        /* Load config window controller */
        let editWindow = ConfigEditWindowController.loadFromNib()
        
        /* Set edit windows main view controller */
        (editWindow.contentViewController as! ConfigEditViewController).mainViewController =  viewController
                
        /* Display config file edit window */
        editWindow.showWindow(self)
        
        /* Set main ViewController's editing window */
        viewController!.editWindow = editWindow.window
    }
    
    /*
     * Kills all processes, for dock menu
     */
    @objc func quitAndKillAllDock(){
        exec_teardown_and_kill()
    }
    
    /*
     * Sets the app to terminate when it is closed
     *
     * Returns true
     */
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        NSApplication.shared.terminate(self)
        return true
    }
}

