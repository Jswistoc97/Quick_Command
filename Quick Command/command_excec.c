/*
 * command_exec.c
 * Created by Joseph Swistock on 11/10/20
 *
 * This file includes code pertaining to logging
 * and executing commands.
 */

#include "command_excec.h"

/* Globals */
FILE *log_file;                 /* Log file, command_exec_log.txt */
p_node *p_stack;                /* Stack of processes */

/*
 * Formats and appends string to the log file, command_exec_log.txt
 */
void add_to_log(char * format, ...){
    
    /* Create new buffer */
    char str[strlen(format) + 2];
    
    /* Insert format string followed by new line into buffer */
    sprintf(str, "%s\n\n", format);
    
    /* Initialize variable arguments starting after 'format' */
    va_list arg;
    va_start(arg, format);
    
    /* Sanity check */
    if (log_file == NULL){
        
        /* Print error message to standard error */
        fprintf(stderr, "Unable to write to command_exec_log.txt.\nTry to write:\n");
        vfprintf(stderr, str, arg);
    }
    else{
        
        /* Call print command that does formatting */
        vfprintf(log_file, str, arg);
        fflush(log_file);
        
    }
    va_end(arg);
}

/*
 * Formats and prints string to standard error and, if possible, to log_file, command_exec_log.txt
 */
void print_error(const char *format, ...){
    
    /* Create new buffer */
    char str[strlen(format) + 13];
    
    /* Insert error text, format string, and new line into buffer */
    sprintf(str, "*****Error: %s\n\n", format);
    
    /* Initialize variable arguments starting after 'format' */
    va_list arg;
    va_start(arg, format);
    
    /* Call print command that does formatting */
    vfprintf(stdout, str, arg);
    
    va_end(arg);
    
    /* Add to log_file, command_exec_log.txt, if it exists */
    if (log_file != NULL){
        
        /* Reinitialize variable arguments starting after 'format' */
        va_list arg;
        va_start(arg, format);
        
        /* Call print command that does formatting */
        vfprintf(log_file, str, arg);
        
        va_end(arg);
        fflush(log_file);
    }
}

/*
 * Allows swift code to call print_error
 */
void swift_error(char* message){
    print_error("%s from Swift\n", message);
}

/*
 * Pushes process node onto process stack
 */
void push_process(int pid){
    
    /* Allocate memory */
    p_node *new_process = malloc(sizeof(p_node));
    
    /* Sanity check */
    if (new_process == NULL){
        
    }
    /* Set pid */
    new_process->pid = pid;
    
    /* Set the next node */
    new_process->next = p_stack;
    
    /* Change global */
    p_stack = new_process;
}

/*
 * Pops process node off the top of the process stack
 *
 * Returns process id of popped process
 */
int pop_process(){
    int pid = p_stack->pid;
    
    /* Set reference to the top */
    p_node *top = p_stack;
    
    /* Set next one */
    if (p_stack != NULL){
        p_stack = p_stack->next;
    }
    
    /* Free top */
    free(top);
    
    /* Return pid */
    return pid;
}

/*
 * Frees all process nodes
 *
 * NOTE: Does not kill processes
 */
void free_stack(){
    
    /* While there are still processes */
    while (p_stack != NULL){
        
        /* Pop off the stack, which also frees it */
        pop_process();
    }
}

/*
 * Frees stack and kills all processes
 */
void kill_all_processes(){
    int pid;
    
    /* While there are still processes */
    while (p_stack != NULL){
        
        /* Pop off the stack, which also frees it */
        pid = pop_process();
        
        /* Kill process */
        kill(pid, SIGKILL);
        
        /* Log that process was killed */
        add_to_log("Killed process: %d", pid);
    }
}

/*
 * This initializes the program to execute commands
 */
void exec_init(char *directory){
        
    /* Change working directory */
    chdir(directory);
    
    /* Open log_file */
    log_file = fopen("command_exec_log.txt", "w");
    
    /* Sanity check */
    if (log_file == NULL){
        print_error("Unable to open command_exec_log.txt in %s", directory);
    }
    else{
        /* Create first log */
        add_to_log("Begin logging.");
    }
    
    /* Set process stack pointer to NULL */
    p_stack = NULL;
}

/*
 * Executes a command on a separate thread
 *
 * Returns process ID of the child thread
 */
int execute_command(char *command){
    int fork_return, current_stack_pid;
    char mod_cmd[strlen(command) + 6], result_char;
    FILE *output_buffer;
    
    /* Record the top process's pid if possible */
    current_stack_pid = -1;
    if (p_stack != NULL) current_stack_pid = p_stack->pid;
    
    /* Combine std_err with std_out and put
     * it into the modified command buffer
     */
    sprintf(mod_cmd, "%s 2>&1", command);
    
    /* Create new thread to execute the thread */
    fork_return = fork();
    
    /* Sanity check */
    if (fork_return < 0){
        print_error("Cannot fork.");
    }
    
    /* Child thread */
    else if (fork_return == 0){
        
        /* Open stream */
        output_buffer = popen(mod_cmd, "r");
        if (output_buffer == NULL){
            print_error("Unable to create output stream for '%s'.", command);
            exit(0);
        }
        
        /* Read result and write it into log_file */
        add_to_log("Output for '%s':", command);
        while ((result_char = fgetc(output_buffer)) != EOF){

            /* Put output into log_file character at a time */
            if (log_file != NULL){
                fprintf(log_file, "%c", result_char); fflush(log_file);
            }
            
        }
        add_to_log("\nEnd of output of '%s'.", command);

        /* Close stream */
        pclose(output_buffer);
        
        /* Terminate this process */
        exit(0);
    }
    /* Only parent thread should reach here */
    
    /* Push child process onto stack */
    push_process(fork_return);
    
    /* return child's pid */
    return fork_return;
}

/*
 * Called while closing to wrap things up
 */
void exec_teardown(){

    /* Check if log_file is NULL */
    if (log_file != NULL){
        
        /* Final log */
        add_to_log("Done logging.");
        
        /* Close log_file */
        fclose(log_file);
    }
    
    /* Free all memory */
    free_stack();
}

/*
 * Called if user wants to quit and kill all process
 */
void exec_teardown_and_kill(){
    
    /* Check if log_file is NULL */
    if (log_file != NULL){
        
        /* Final log */
        add_to_log("Done logging.");
        
        /* Close log_file */
        fclose(log_file);
    }
    
    /* Free all memory */
    free_stack();
    
    /* Kill every process (including the app itself) */
    kill(0, SIGKILL);
}



