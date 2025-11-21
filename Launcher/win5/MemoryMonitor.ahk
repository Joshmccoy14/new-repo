; Function to get memory usage of a process
GetMemoryUsage(pid) {
    if (!pid)
        return "N/A"
    
    wmi := ComObjGet("winmgmts:")
    queryEnum := wmi.ExecQuery("SELECT WorkingSetSize FROM Win32_Process WHERE ProcessId = " . pid)
    
    for process in queryEnum {
        return Round(process.WorkingSetSize / 1048576, 2) ; Convert bytes to MB
    }
    
    return "N/A"
}

; Function to update memory usage in GUI
UpdateMemoryInGUI(pid, controlName) {
    memoryUsage := GetMemoryUsage(pid)
    GuiControl,, %controlName%, %memoryUsage% MB
    return memoryUsage
}