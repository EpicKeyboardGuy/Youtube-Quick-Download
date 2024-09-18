/*
===================================================================================================================================================================================

¤	Youtube Quick Download.ahk

        --->	By Epic Keyboard Guy
		--->	Last Modified : 2024-09-18

===================================================================================================================================================================================
*/

/*
===================================================================================================================================================================================

¤	AUTO-EXECUTE SECTION

===================================================================================================================================================================================
*/

If (!A_IsAdmin)
{
	Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
}

#Requires AutoHotKey v2
#SingleInstance Ignore

SetWorkingDir A_ScriptDir
SetTitleMatchMode 2 ; 1=Must start with   -   2=Must contain   -   3=Must be Exact Match

TraySetIcon "Youtube Icon.bmp"

f_Error(var_e, var_Mode) ; Unblock Input on Error
{
    BlockInput false

    Return 0
}

OnError(f_Error)

/*
===================================================================================================================================================================================

¤	FIXED VARIABLES		--->	For easy modifications

===================================================================================================================================================================================
*/

VAR_KEY_DELAY := 100

YTDLP_FOLDER := "M:\SYSTEM\Progs (No-Install)\YT-DLP\"
FFMPEG_FOLDER := "M:\SYSTEM\Progs (No-Install)\FFMPEG\"
DEFAULT_DOWNLOAD_FOLDER := "M:\_TEMP\_YT-DLP DOWNLOAD\"

/*
===================================================================================================================================================================================

¤	Ctrl S   --->   Save + Auto-reload

===================================================================================================================================================================================
*/

~^S:: ; Save + Auto-Reload
{
	If (WinActive("ahk_exe Code.exe"))
	{
		Sleep 200
		Reload
		Exit
	}

	Exit
}

/*
===================================================================================================================================================================================

¤	START

===================================================================================================================================================================================
*/

/*
===================================================================================================================================================================================

¤	Shift Win Y		--->	Run Youtube Download.ahk

===================================================================================================================================================================================
*/

+#Y:: ; Download video from current Youtube Page
{
	KeyWait("Shift")
	KeyWait("LWin")
	KeyWait("Y")

    Sleep 200

    if(!WinActive("YouTube"))
    {
        f_ME("Youtube page not found")
    }

    var_URLStart := "https://www.youtube.com/watch?v="
    var_URL := ""
    var_OutputFolder := ""
    var_TempFileFullPath := ""
    var_TempFileName := ""

    BlockInput true
    {
        SetKeyDelay VAR_KEY_DELAY

        Send "^l"
        Sleep 500
        Send "^c"
        Sleep 200

        var_URL := A_Clipboard

        if(SubStr(var_URL, 1, StrLen(var_URLStart)) != var_URLStart)
        {
            f_ME("URL must start with :     " . var_URLStart . "`n`n" . "Current URL :                 " . var_URL)
        }
    }
    BlockInput false

    var_OutputFolder := DirSelect("*" . DEFAULT_DOWNLOAD_FOLDER, 3) . "\"

    if(var_OutputFolder = "\")
    {
        f_ME("No output folder selected.")
    }


    ;--------------------------------------------------------------------------------------------------
    ;	Run YT-DLP
    ;--------------------------------------------------------------------------------------------------

    Loop Files, YTDLP_FOLDER . "_TEMP\" . "*.*"
    {
        FileDelete(A_LoopFileFullPath)
    }

    RunWait("`"" . YTDLP_FOLDER . "yt-dlp.exe`""
            . " --ffmpeg-location `"" . FFMPEG_FOLDER . "ffmpeg.exe`""
            . " `"" . var_URL . "`""
            . " -o `"" . YTDLP_FOLDER . "_TEMP\" . "%(title)s.%(ext)s" . "`"")

    ; f_M("RunWait done")

    Loop Files, YTDLP_FOLDER . "_TEMP\" . "*.mp4"
    {
        var_TempFileFullPath := A_LoopFileFullPath
        var_TempFileName := A_LoopFileName
    }

    if(var_TempFileName = "")
    {
        f_ME("No temp file")
    }

    ; f_M(var_TempFileFullPath)
    ; f_M(var_TempFileName)


    ;--------------------------------------------------------------------------------------------------
    ;	Convert to h264 with FFMPEG
    ;--------------------------------------------------------------------------------------------------

    RunWait("`"" . FFMPEG_FOLDER . "ffmpeg.exe" . "`""
        . " " . "-i " . "`"" . var_TempFileFullPath . "`""
        . " " . "-vcodec libx264 -acodec aac"
        . " " . "`"" . var_OutputFolder . var_TempFileName . "`"")

    ; FileCopy(var_TempFileFullPath, var_OutputFolder . var_TempFileName, true) ; Use this line instead of running FFMPEG if you dont want to convert.

    FileDelete(var_TempFileFullPath)

    ;--------------------------------------------------------------------------------------------------
    ;	Open output folder
    ;--------------------------------------------------------------------------------------------------

    Run("`"" . var_OutputFolder . "`"")

    Exit






    /*
    ===================================================================================================================================================================================

    ¤	f_ME()		--->	ERROR MESSAGE + EXIT

                    --->	I know... I know... I could just use a MsgBox() and then Exit. But this is way better because you can Copy/Paste the text :)
                            Not necessary at all for this particular script, but this is my go-to option for error message. Feel free to use it if you like !

    ===================================================================================================================================================================================
    */

    f_ME(var_Text := "Error", var_LineNumber := 0)
    {
        BlockInput false

        var_ShowOption := "Autosize Center"

        gui_M := Gui("+AlwaysOnTop -MinimizeBox")
        gui_M.OnEvent("Close", nf_GuiClose)
        gui_M.OnEvent("Escape", nf_GUiClose)

        gui_M.AddEdit("xm ReadOnly -Tabstop", var_Text)

        gui_M.AddText("xm", "`n`n")

        if (var_LineNumber > 0)
        {
            gui_M.AddText("", "@LineNumber : " . var_LineNumber . "`n`n")
        }

        gui_M.AddButton("xm W100 H30 +Default", "Exit").OnEvent("Click", nf_GUiClose)

        if (var_LineNumber > 0)
        {
            gui_M.AddButton("x+m W100 H30", "Edit").OnEvent("Click", nf_GuiEditBtn)
        }

        gui_M.Show(var_ShowOption)

        TraySetIcon(A_IconFile, , true)
        Pause

        nf_GuiEditBtn(*)
        {
            Run "C:\M-DRIVE\SYSTEM\AutoHotKey\Microsoft VS Code\Code.exe" . " " . "-r -g" . " " . "`"" . A_ScriptFullPath . "`"" . ":" . var_LineNumber

            nf_GuiClose()
        }

        nf_GuiClose(*)
        {
            gui_M.Destroy()

            Pause false
            TraySetIcon(A_IconFile, , false)
        }

        Exit
    }
}
