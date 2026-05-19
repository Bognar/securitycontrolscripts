An Unquoted Service Path vulnerability is a classic Windows flaw that occurs when a system service points to an executable file path containing spaces, but the path is not wrapped in quotation marks.

For a machine to actually be vulnerable to exploitation (Privilege Escalation), all three of the following conditions must be met simultaneously:

1. The service path must contain spaces and lack quotes
Windows uses spaces as delimiters when processing commands. If a path has spaces and isn't enclosed in " ", the Windows Service Control Manager gets confused about where the folder path ends and where the executable filename begins.

Vulnerable: C:\Program Files\Custom Software\My Service\daemon.exe

Secure: "C:\Program Files\Custom Software\My Service\daemon.exe"

2. The service must run with elevated privileges
The goal of exploiting this flaw is usually Privilege Escalation (going from a standard user to an administrator). For this to be useful to an attacker, the target service must run under a high-privilege account, such as:

NT AUTHORITY\SYSTEM

LocalSystem

LocalService

If the service already runs as a low-privileged local user, hijacking it doesn't give the attacker any new powers.

3. A standard user must have write permissions to an intercepting folder
This is the critical "missing link" that turns a configuration oversight into a dangerous exploit. Windows will sequentially guess where the executable is by appending .exe to each chunk of the path before a space.

An attacker needs permission to drop a malicious file into one of those parent directories.
