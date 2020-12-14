/*
 * ConfigEditViewController.swift
 * Created by Joseph Swistock on 11/12/20
 *
 * Contains ConfigEditViewController, which is the view controller for the config file editor
 * Also contains TextView, which is a subclass of NSTextView, the editor's text view
 */

import Cocoa

/*
 * ConfigEditViewController class is the main driver behind the GUI of the config editor
 * It allows the user to edit the config file without finding it on their own
 */
class ConfigEditViewController: NSViewController {
    
    /* Working directory for the program */
    let pathname: String = "/Users/" + NSUserName() + "/Quick_Command/"
    
    /* Variables */
    var mainViewController: ViewController?             /* The main window's view controller */
    var initialString: String?                          /* Initial loaded string */
    
    /* User interface objects */
    @IBOutlet var EditTextView: EditorTextView!         /* The Text view of the editor */
    
    /*
     * This is called when the view for the config editor is loaded
     * It does various configuration things
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Set font for editor */
        EditTextView.font = NSFont(name: "Courier", size: 16)
        
        /* Load from the config file */
        if !(loadConfig()){
            
            /* If failure */
            ViewController.debug_error_alert(message: "Uh oh!", file: #file, line: #line)
            return
        }
        
        /* Save initial text */
        initialString = EditTextView.string
        
        /* Set reference in text view */
        EditTextView.viewController = self
    }
    
    /*
     * This reads in the ASCII text from the config file and puts it into the text editor
     *
     * Returns true if successful, false if not
     */
    func loadConfig() -> Bool{
        var contents: String? = nil
        
        /* Ensure there is a working directory */
        if !(FileDriver.prepareDirectory(path: pathname)){
            
            /* If working directory could not be prepared */
            ViewController.debug_error_alert(message: "Could not prepare " + pathname, file: #file, line: #line)
            /* Program will be terminated */
        }
        
        /* Ensure there is a working config file */
        if !(FileDriver.prepareFile(path: pathname + "config.txt", initContents: "#Config file, put button titles and commands in here\n")){
            
            /* If config file could not be preapared */
            ViewController.debug_error_alert(message: "Could not prepare " + pathname + "config.txt", file: #file, line: #line)
            /* Program will terminate */
        }
        
        /* Read config file */
        contents = FileDriver.readASCIIFile(path: pathname + "config.txt")
        
        /* Sanity check */
        if (contents == nil){
            return false
        }
        
        /* Put contents of congif file into the text editor */
        EditTextView.string = contents!
        return true
    }
    
    /*
     * Saves text from the editor to the config file
     *
     * Associated with the 'Save' button
     */
    @IBAction func saveEvent(_ sender: Any) {
        
        /* Get text from text editor */
        let contents = EditTextView.string
        
        /* Write it to file */
        if !(FileDriver.writeASCII(path: pathname + "config.txt", contents: contents)){
            
            /* If there was an error */
            ViewController.debug_warning_alert(message: "Unable to write to config.txt", file: #file, line: #line)
        }
        
        /* Apply changes */
        if (mainViewController != nil){
            mainViewController!.getButtonsFromConfigFile()
        }
    }
    
    /*
     * Undoes every change since the beginning of the editing session
     *
     * Associated with the 'Undo All' button
     */
    @IBAction func undoEvent(_ sender: Any) {
        
        /* Reload text from beginning of session */
        if (initialString != nil){
            EditTextView.string = initialString!
        }
    }
    
    /*
     * Resets the editor to contain the text from config file
     *
     * Associated with the 'Reset From Last Save' button
     */
    @IBAction func resetFromLastSave(_ sender: Any) {
        
        /* Reload text from config */
        if !(loadConfig()){
            
            /* If failure*/
            ViewController.debug_error_alert(message: "Could not load " + pathname + "config.txt", file: #file, line: #line)
            /* App will terminate */
        }
    }
    
}

/*
 * TextView is a sublass of NSTextView
 *
 * Implemented so we can make use of the user's 'Command-S' key press
 */
public class EditorTextView: NSTextView{
    
    /* Variables */
    var viewController: ConfigEditViewController?   /* Config editor's view controller */
    
    /*
     * Called when the user presses down a key in the text view
     */
    public override func keyDown(with event: NSEvent) {
        
        /* Check if the key was pressed with Command */
        if event.modifierFlags.intersection(.deviceIndependentFlagsMask).contains(.command) {
            
            /* If the user did a 'Command-S' */
            if (event.keyCode == 1 && viewController != nil){
                viewController!.saveEvent(self)
                
                /* Return early, or else super.keyDown will make a noise */
                return
            }
        }
        super.keyDown(with: event)
    }
}
