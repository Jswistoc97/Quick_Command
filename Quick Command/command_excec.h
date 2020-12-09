/*
 * command_exec.h
 * Created by Joseph Swistock on 11/10/20
 *
 * Header file to command_exec.c
 */

#ifndef command_excec_h
#define command_excec_h

/* Includes */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include <stdarg.h>
#include <signal.h>

/*
 * Struct representing a process
 */
typedef struct p_node{
    int pid;                    /* Process ID */
    struct p_node *next;        /* Next process node */
}p_node;

void add_to_log(char * format, ...);
void print_error(const char *format, ...);
void swift_error(char* message);
void kill_all_processes(void);
void exec_init(char directory[]);
int execute_command(char *command);
void exec_teardown(void);
void exec_teardown_and_kill(void);

#endif /* command_excec_h */
