/*
 * ViewController.swift
 * Created by Joseph Swistock on 11/10/20
 *
 * Contains ViewController class, which subclasses the window's NSViewController
 * ViewController is the primary class used, as it drives the visual and interactive elements of the app
 *
 * Also contains the Button class, a subclass of the NSButton class
 */

import Cocoa

/*
 * ViewController class is the main driver behind the GUI of the application.
 * It controls the generation of buttons and the reading of the config file
 */
class ViewController: NSViewController {
    
    /* Working directory for the program */
    let pathname: String = "/Users/" + NSUserName() + "/Quick_Command/"
    
    /* Constants */
    let horizontal_indent: CGFloat = 15     /* Left indent for the buttons */
    let vertical_indent: CGFloat = 10       /* Top indent for the buttons */
    let row_scalar: CGFloat = 21.3          /* Approximate height of each row of buttons */
    let char_width_scalar: CGFloat = 9.6    /* Approximate width of each character of the font */
    
    /* Variables */
    var button_tint: NSColor = .black       /* Tint color of the buttons */
    var inView: Bool = true                 /* Indicates whether the program isn't hidden or minimized */
    var grid: NSGridView?                   /* Grid that contains buttons */
    var editWindow: NSWindow?               /* Config editor window */
    
    /* User interface objects */
    @IBOutlet weak var noCommandsAvailableLabel: NSTextField!   /* Label that indicates there are no buttons */
    
    /*
     * This is called when the view is loaded.
     *
     * This contains the majority of setup for the app.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Prepare the working directory */
        if !(FileDriver.prepareDirectory(path: pathname)){
            
            /* If working directory could not be prepared */
            ViewController.debug_error_alert(message: "Could not prepare " + pathname, file: #file, line: #line)
            /* Program will be terminated */
        }
        
        /* Prepare config file */
        if !(FileDriver.prepareFile(path: pathname + "config.txt")){
            
            /* If config file could not be preapared */
            ViewController.debug_error_alert(message: "Could not prepare " + pathname + "config.txt", file: #file, line: #line)
            /* Program will terminate */
        }
        
        /* Initialize C code */
        let dir = ViewController.get_c_string(str: pathname)
        exec_init(dir)
        dir.deallocate()
        
        /* Initialize grid */
        grid = NSGridView(views: [])
        
        /* Turn off resizing for the grid */
        grid!.translatesAutoresizingMaskIntoConstraints = false
        
        /* Create frame for grid */
        grid!.frame = NSRect(x: horizontal_indent, y: vertical_indent, width: 1.0e5, height: 1.0e5)
        
        /* Set the spacing between rows */
        grid!.rowSpacing = 1.0
        
        /* Add to the view */
        view.addSubview(grid!)
        
        /* Make app refresh in the background */
        background_refresher()
        
        /* Set view's controller to self */
        (view as! View).viewController = self
        
        /* If user is in dark mode */
        if (UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"){
            
            /* Set tint of buttons to white */
            button_tint = .white
        }
        
        /* If user is in light mode */
        else{
            /* Set tint of buttons to black */
            button_tint = .black
        }
        
        /* Make reference to this view controller in the app delegate */
        (NSApplication.shared.delegate as! AppDelegate).viewController = self
    }
    
    /*
     * This is called every time the view appears
     * Including on launch and un-minimizing
     */
    override func viewDidAppear() {
        super.viewDidAppear()
        
        /* Get buttons from the config file
         *
         * Note: Despite, getButtonsFromConfigFile() being a setup function
         * getButtonsFromConfigFile() is in viewDidAppear()
         * and NOT viewDidLoad(). This is because the window
         * cannot change size before it is displayed.
         * It would crash if called in viewDidLoad().
         *
         * Additionally, getButtonsFromConfigFile() is also used to refresh
         * the buttons in the event that config.txt changed while the app is running
         */
        getButtonsFromConfigFile()
        
        /* App is now in view */
        inView = true
    }
    
    /*
     * This is called when the view has disappeared
     */
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        /* App is not in view */
        inView = false
    }
    
    /*
     * This adds a button and corresponding command to the window
     */
    func addButton(title: String, command: String){
        
        /* Hide 'No commands available' text */
        noCommandsAvailableLabel.isHidden = true
        
        /* Initialize button with title, target, and the action (what is done when clicked) */
        let button = Button(title: title, target: self, action: #selector(self.execute(_:)))
        
        /* Set command */
        button.command = command
        
        /* Remove border */
        button.isBordered = false
        
        /* Make bezel invisible */
        button.bezelColor = .clear
        
        /* Set tint color */
        button.contentTintColor = button_tint
        
        /* Set font */
        button.font = NSFont(name: "Courier-Bold", size: 16)
        
        /* Add button to grid */
        grid!.addRow(with: [button])
                
        /* Resize window */
        set_window_frame(title: title)
    }
    
    /*
     * Creates the buttons for the grid fro the config file
     *
     * config.txt allows for comments, extra lines, and extra white space
     * Ignoring those, the format is as follows.
     * Every button title is followed by it's associated command, each on their own line. Example:
     *
     * Button title
     * command
     */
    func getButtonsFromConfigFile(){
        
        /* Get every useful line from config.txt */
        let lines = getStringsFromConfig()
                
        /* Set variables for loop */
        var ctr = 0
        var title: String
        var command: String
        var button: Button
        
        /* If no lines were read */
        if (lines.count == 0){
            
            /* Display 'No commands available' label */
            noCommandsAvailableLabel.isHidden = false
            
            /* Reset grid by deleting buttons */
            while(grid!.numberOfRows != 0){
                
                /* Delete buttons */
                grid!.cell(atColumnIndex: 0, rowIndex: 0).contentView!.removeFromSuperview()
                grid!.removeRow(at: 0)
            }
            
            /* Reset window size */
            let size = NSSize(width: 175, height: 75)
            let frame = NSRect(origin: view.window!.frame.origin, size: size)
            view.window!.setFrame(frame, display: true)
            return
        }
        
        /* For every 2 lines */
        while ctr < lines.count - 1{
            
            /* Get title and command */
            title = lines[ctr]
            command = lines[ctr + 1]
            
            /* If there are less buttons OR same number of buttons from config than are in the grid */
            if (grid!.numberOfRows <= (ctr / 2)){

                /* Add button */
                addButton(title: title, command: command)
            }
            
            /* If there are already buttons */
            else {
                /* Get button */
                button = (grid!.cell(atColumnIndex: 0, rowIndex: ctr / 2).contentView as! Button)
                
                /* Update command in case it changed */
                button.command = command
                
                /* If the title from config doesn't match title of button */
                if (button.title != title){
                    
                    /* Replace the button's title; no need to create a whole new button */
                    button.title = title
                }
                
            }
            
            /* Increment counter by 2 */
            ctr += 2
        }
        
        /* Set ctr to reflect current position in grid */
        ctr -= 2
        ctr = lines.count / 2

        /* Clean up extra buttons */
        while (ctr < grid!.numberOfRows){
                        
            /* Delete button */
            grid!.cell(atColumnIndex: 0, rowIndex: ctr).contentView!.removeFromSuperview()
            grid!.removeRow(at: ctr)
        }
        
        /* Resize window */
        set_window_frame(title: nil)
    }
    
    /*
     * Reads config file and returns the results, removing white space, comments, and extra lines
     *
     * Returns a string array containing the needed information from config.txt
     */
    func getStringsFromConfig() -> [String]{
        
        /* Read config file */
        let contents = FileDriver.readASCIIFile(path: pathname + "config.txt")
        
        /* If config file does not exist */
        if (contents == nil){
                        
            /* Create it */
            if (FileDriver.writeASCII(path: pathname + "config.txt", contents: "")){
                
                /* Writing file was unsuccessful */
                ViewController.debug_error_alert(message: "Could not write config file", file: #file, line: #line)
                /* Will terminate program */
            }
            
            return []
        }
                
        /* Create list of lines  */
        let lines = contents!.split(separator: "\n")
        
        /* If there is no contents of file */
        if (lines.count == 0){
            return []
        }
                
        /* Prepare variables for use in for loop */
        var trailing_ws_end = false
        var array: [Character] = []
        var last_index: Int?
        var toReturn: [String] = []
        var temp = ""
        var c: Character
        
        /*
         * config.txt is allowes empty lines, lines filled with exclusively whitespace,
         * and comments (indicated by '#'). All of these are removed
         */
        
        /* For every line of the contents */
        for substr_line in lines{
            
            /* Convert line from Substring to Character array */
            array = Array(substr_line)
            
            /* If line is not empty */
            if (array.count != 0){
                
                /* Set the last index of the line to be the beginning of a comment */
                last_index = array.firstIndex(of: "#")
                
                /* If there was no comment */
                if (last_index == nil){
                    
                    /* Set last index to be the last reachable index */
                    last_index = array.count - 1
                }
                
                /* If there was a comment */
                else{
                    
                    /* Set last index to be the last index before '#', which indicates a comment */
                    last_index! -= 1
                }
                
                /* Scroll backwards through the array, ignoring all trailing white space */
                while (last_index! >= 0){
                    c = array[last_index!]
                    
                    /* If current character is not white space */
                    if !(c.isWhitespace){
                        
                        /* End trailing white space */
                        trailing_ws_end = true
                        
                        /* Insert character at the beginning of temp */
                        temp.insert(c, at: .init(utf16Offset: 0, in: temp))
                    }
                    
                    /* If current character is white space */
                    else{
                        
                        /* If this is not trailing white space */
                        if (trailing_ws_end){
                            
                            /* Insert character at the beginning of temp */
                            temp.insert(c, at: .init(utf16Offset: 0, in: temp))
                        }
                    }
                    last_index! -= 1
                }
                /* End while loop */
                
                /* If temp isn't empty */
                if (temp != ""){
                    
                    /* Append the temporary string to the return array */
                    toReturn.append(temp)
                    
                    /* Reset temp */
                    temp = ""
                }
            }
        }
        
        /* Return array filled with every nonemoty line of config without comments or trailing white space */
        return toReturn
    }
    
    
    /*
     * Executes command associated with the sending button
     *
     * Note: This function is designed to be the 'action' within any of the buttons
     */
    @objc func execute(_ sender: Button){
                
        /* Initialize C compatible pointer */
        let cmd = ViewController.get_c_string(str: sender.command)
        
        /* Call C code to execute command */
        execute_command(cmd)
        
        /* Free memory allocated by cmd pointer */
        cmd.deallocate()
    }
    
    /*
     * Called when the user changes themes
     */
    func theme_change(){
        
        /* If user is in dark mode */
        if (UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"){
            
            /* Set tint of button to white */
            button_tint = .white
        }
        
        /* If user is in light mode */
        else{
            /* Set tint of button to black */
            button_tint = .black
        }

        /* Create button for referencing */
        var button: NSButton

        /* For every button */
        for ctr in 0...(grid!.numberOfRows - 1){
            
            /* Get button from grid */
            button = (grid!.cell(atColumnIndex: 0, rowIndex: ctr).contentView as! Button)
            
            /* Change tint */
            button.contentTintColor = button_tint
        }
    }
    
    /*
     * Occasionally (every 30 seconds) syncs the config file and the app
     */
    func background_refresher(){
        
        /* Make a background thread */
        DispatchQueue.global(qos: .background).async {
            
            /* Make it run forever */
            while true{
                
                /* Sleep for 30 seconds */
                sleep(30)
                
                /* If app is not hidden AND config is not being edited */
                if self.inView && self.editWindow == nil {
                    
                    /* Temporarily put on the main thread */
                    DispatchQueue.main.async {
                        
                        /* Synch buttons with config file */
                        self.getButtonsFromConfigFile()
                    }
                }
            }
        }
    }
    
    /*
     * Sets the window's size according to the widest buttons
     * and according to the number of buttons
     *
     * Doesn't find the widest button if there is a given title;
     * all it does is checks if the given title will make the
     * window wider, and, if it does, resizes the width.
     */
    func set_window_frame(title: String?){
        var unwrapped_title: String = ""
        
        /* If there is no title */
        if (title == nil){
            /* Create button for reference */
            var button: Button
            
            /* For every button in the grid */
            for ctr in 0...(grid!.numberOfRows - 1){
                button = (grid!.cell(atColumnIndex: 0, rowIndex: ctr).contentView as! Button)
                
                /* Set unwrapped_title to be the largest */
                if unwrapped_title == "" || unwrapped_title.count < button.title.count{
                    unwrapped_title = button.title
                }
            }
        }
        
        /* If there is a title */
        else{
            /* set unwrapped_title to be an unwrapped copy of title */
            unwrapped_title = title!
        }
        
        /* Calculate the new window width */
        var newWidth = (2 * horizontal_indent) + (CGFloat(unwrapped_title.count) * char_width_scalar)
        
        /* If calculated width is smaller than current width AND this isn't a complete resize */
        if newWidth < view.window!.frame.width && title != nil {
            
            /* Set newWidth to the current width */
            newWidth = view.window!.frame.width
        }
        
        /* Calculate the new window height */
        let newHeight = (row_scalar * CGFloat(grid!.numberOfRows)) + vertical_indent + 35
        
        /* Create new frame for window */
        let size = NSSize(width: newWidth, height: newHeight)
        let frame = NSRect(origin: view.window!.frame.origin, size: size)
        
        /* Resize window */
        view.window!.setFrame(frame, display: true)
    }
    
    /*
     * Creates a char pointer compatible with c code from the given string
     *
     * Returns the created pointer
     *
     * NOTE: Must be deallocated after use to limit potential fragmentation
     */
    static func get_c_string(str: String) -> UnsafeMutablePointer<Int8>{
        
        /* Initialize pointer */
        let toReturn = UnsafeMutablePointer<CChar>.allocate(capacity: str.count + 1)
        
        /* Add null terminator */
        toReturn[str.count] = 0
        
        /* Convert String to [Char] */
        let arr = Array(str)
        
        /* Insert characters into allocated memory */
        for i in 0...arr.count - 1{
            if arr[i].isASCII{
                toReturn[i] = Int8(arr[i].asciiValue!)
            }
        }
        
        /* Return value */
        return toReturn
    }
    
    /*
     * Presents a popup message for the user
     */
    public static func warning_alert(title: String, message: String){

        /* Create alert */
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = title
        alert.informativeText = message
        
        /* Show alert */
        alert.runModal()
    }
    
    /*
     * Presents a popup debug message, logs it
     *
     * file and line are to be passed as #file and #line
     */
    public static func debug_warning_alert(message: String, file: String, line: Int){
        
        /* Create char pointer for C */
        let msg = get_c_string(str: message + "\nfile: " + file + "\nline: " + line.description)
        
        /* Call C error logger */
        swift_error(msg);
        
        /* Deallocate */
        msg.deallocate()

        /* Create alert */
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "DEBUG Warning"
        alert.informativeText = message + "\nfile: " + file + "\nline: " + line.description
        
        /* Show alert */
        alert.runModal()
    }
    
    /*
     * Presents a popup debug message, terminates the program
     *
     * file and line are to be passed as #file and #line
     */
    public static func debug_error_alert(message: String, file: String, line: Int){
        
        /* Create char pointer for C */
        let msg = get_c_string(str: message + "\nfile: " + file + "\nline: " + line.description)
        
        /* Call C error logger */
        swift_error(msg);
        
        /* Deallocate */
        msg.deallocate()

        /* Create alert */
        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = "DEBUG Error"
        alert.informativeText = message + "\nfile: " + file + "\nline: " + line.description
        
        /* Show alert */
        alert.runModal()
        
        /* Teardown C code */
        exec_teardown()
        
        /* Terminate program */
        exit(0)
    }
    
}


/*
 * Class overide to add a command to a button
 */
public class Button: NSButton{
    var command: String = ""    /* The command line command that will be executed */
    
    /*
     * Override event when mouse clicks down to make it clear to the user a button is being clicked
     */
    public override func mouseDown(with event: NSEvent) {
        
        /* Save previous tint color */
        let color = contentTintColor
        
        /* As mouse clicks down, tint color to gray */
        contentTintColor = .gray
        
        /* Mouse is down */
        super.mouseDown(with: event)
        
        /* As mouse lifts up, change tint back */
        contentTintColor = color
    }
}
