Set WshShell = CreateObject("WScript.Shell")

' 1. Create the virtual display
WshShell.Run "adb shell settings put global overlay_display_devices 1920x1200/240", 0, True

' 2. Execute dumpsys display and capture output to locate the display ID
Set oExec = WshShell.Exec("cmd /c adb shell dumpsys display")
simulatedDisplay = ""

Do While Not oExec.StdOut.AtEndOfStream
    line = oExec.StdOut.ReadLine()
    If InStr(line, "mDisplayId=") > 0 Then
        ' Extract value after mDisplayId=
        parts = Split(line, "mDisplayId=")
        If UBound(parts) >= 1 Then
            ' Split by space or line end to isolate the ID
            idVal = Trim(Split(parts(1), " ")(0))
            If idVal <> "0" And idVal <> "" Then
                simulatedDisplay = idVal
            End If
        End If
    End If
Loop

' 3. Start scrcpy and wait for it to close
If simulatedDisplay <> "" Then
    scrcpyCmd = "scrcpy -f -K --mouse-bind=++bh -S --stay-awake --display-id=" & simulatedDisplay
    WshShell.Run scrcpyCmd, 0, True
End If

' 4. Clean up the virtual display after scrcpy exits
WshShell.Run "adb shell settings put global overlay_display_devices none", 0, True
