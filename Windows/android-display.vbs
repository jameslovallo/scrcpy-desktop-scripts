Set WshShell = CreateObject("WScript.Shell")
WshShell.Run "scrcpy --new-display -x -K --mouse-bind=++bn --stay-awake", 0, True
