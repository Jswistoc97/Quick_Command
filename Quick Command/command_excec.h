/*
 * command_exec.h
 * Created by Joseph Swistock on 11/10/20
 *
 * Header file to command_exec.h
 */

#ifndef command_excec_h
#define command_excec_h

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdarg.h>

#endif /* command_excec_h */

void add_to_log(char * format, ...);
void print_error(const char *format, ...);
void swift_error(char* message);
void kill_all_processes(void);
void exec_init(char directory[]);
int execute_command(char *command);
void exec_teardown(void);
void exec_teardown_and_kill(void);
