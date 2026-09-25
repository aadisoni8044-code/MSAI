# Kora Security & Safety Model

## Core Security Directives

Kora operates strictly as a controlled developer tool and prohibits dangerous, malware-like execution.

### 1. Explicit Permission System
Before executing build operations, Kora prompts the user to review and grant specific permissions:
* Project folder access
* Execute build commands
* Create files inside project / output directory
* Install Python packages into target virtual environment
* Internet access for downloading packages

### 2. Command Validation Layer
All external process calls pass through `CommandRunner.is_command_safe()`. Any command containing dangerous system calls (`del /f /s /q c:\`, `rmdir /s /q`, `reg delete`, `netsh`, etc.) is blocked immediately before process creation.

### 3. Safe Subprocess Execution
* Commands are passed as argument lists (`List[str]`), avoiding shell string execution (`shell=False`).
* Subprocesses run strictly with controlled CWD set to the project workspace.
* Subprocess timeout and user cancellation are strictly enforced.

### 4. Prohibited Automatic Actions
Kora will NEVER automatically:
* Delete arbitrary system or user files
* Modify Windows system files or registry keys
* Disable antivirus or alter OS security policies
* Execute unvalidated commands returned from AI models or remote servers
* Upload project source code to external cloud endpoints
