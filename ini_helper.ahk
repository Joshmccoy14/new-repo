; Global INI cache
global iniCache := {}

; Initialize all INI files at startup
InitializeINICache() {
    global iniCache, SettingsFile, iniFile
    iniCache.settings := ParseINI(SettingsFile)
    iniCache.main := ParseINI(iniFile)
}

; Fast INI replacement using FileRead
ParseINI(filePath) {
    ini := {}
    FileRead, content, %filePath%
    if (ErrorLevel)
        return ini
        
    currentSection := ""
    Loop, Parse, content, `n, `r
    {
        line := Trim(A_LoopField)
        if (line = "" || SubStr(line, 1, 1) = ";")
            continue
            
        if (RegExMatch(line, "^\[(.+)\]$", match)) {
            currentSection := match1
            ini[currentSection] := {}
        } else if (currentSection != "" && InStr(line, "=")) {
            pos := InStr(line, "=")
            key := Trim(SubStr(line, 1, pos - 1))
            value := Trim(SubStr(line, pos + 1))
            ini[currentSection][key] := value
        }
    }
    return ini
}

; Get value with default
GetINIValue(ini, section, key, default := "") {
    if (ini.HasKey(section) && ini[section].HasKey(key))
        return ini[section][key]
    return default
}

; Helper functions for your script
GetSettingsValue(key, default := "") {
    global iniCache
    return GetINIValue(iniCache.settings, "Settings", key, default)
}

GetChatBuffCommand(index, default := "") {
    global iniCache
    return GetINIValue(iniCache.settings, "ChatBuffCommands", "Command" . index, default)
}

GetChatBuffCount(default := 0) {
    global iniCache
    return GetINIValue(iniCache.settings, "ChatBuffCommands", "Count", default)
}

; Reload cache when INI files change
ReloadINICache() {
    InitializeINICache()
}