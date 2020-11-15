Quick Command
By Joseph Swistock

This app generates a list of buttons, each of which executes a Terminal command.

How to set up:
Upon launching, there will be no buttons, because the config has nothing in it.
To edit the config file and add commands, you must go to 'File' and then 'Open Config File'.
Then, an editor will open up. The config file follows some basic rules.
  -A valid line is a non-empty line with any uncommented text.
  -Button titles are always on the previous valid line of their associated commands.
  -Commands for those titles are on the valid line after.
  -Comments (any text following '#') and trailing white space are ignored.
  
Example config:

   #This is a comment
   
   Hello, world! #This is the button title
   echo Hello, world! #This is the command
   #The output of 'Hello, World!' is in command_exec_log.txt
   
   Launch Firefox #Another button title
   open /Applications/Firefox.app #Another command
  
All outputs are logged in a file called command_exec_log.txt, found in the automatically
created "Quick_command" directory in your user profile (/Users/<Your username>/Quick_Command/command_exec_log.txt).
