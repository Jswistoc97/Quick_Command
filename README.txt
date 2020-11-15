Quick Command
By Joseph Swistock

This app generates a list of buttons, each of which executes a Terminal command.

How to set up:
Upon launching Quick Command.app for the first time, it will create a directory (Quick_Command) in your user folder
For me, this is: /Users/joeswistoc/Quick_Command/

In that directory, there are 2 files: 
  config.txt
    Where you enter in button titles and their associated commands
  
  and command_exec_log.txt
    Where the outputs of your commands as well as outputs of the program are
    
In config.txt, you may enter in button titles and the associated command, each on their own line.
You are allowed empty lines, and comments (which are initiated by '#')

Example:

   #This is a comment
   
   Hello, world! #This is the button title
   echo Hello, world! #This is the command
   #The output of 'Hello, World!' is in command_exec_log.txt
   
   Launch Firefox #Another button title
   open /Applications/Firefox.app #Another command