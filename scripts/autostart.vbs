' Start JARVIS at logon with no console window.
'
' Registered as a Windows scheduled task ("JARVIS"), which runs it through
' wscript.exe; double-clicking it works the same way. The project folder is
' derived from this script's own location, so the checkout can move without
' the task needing to be re-registered.
'
' Safe mode: no --writes, so JARVIS can talk and drive his own interface but
' cannot run commands, change files or drive devices. Add --writes below to
' allow those.
Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

root = fso.GetParentFolderName(fso.GetParentFolderName(WScript.ScriptFullName))
shell.CurrentDirectory = root
shell.Run "node.exe scripts\start.mjs", 0, False
