@echo off
setlocal enabledelayedexpansion
REM ----------------------------------------------------------------------
REM pecoを使ってExplorerを開く
REM USAGE) peco-explorer.bat
REM ----------------------------------------------------------------------
chcp 65001 >nul
REM --------------------------------------------------
REM 環境設定
REM --------------------------------------------------
REM 引数なしの場合のデフォルト検索ルートディクトリ
set PECO_DEFAULT_ROOT_DIR=D:\coma\work\
set PECO_CMD=peco --select-1 --prompt "GoTo>"
set PECO_BOOKMARK=%USERPROFILE%\.peco-bookmarks
set PECO_TEMPLIST=%USERPROFILE%\.peco-temp
REM set NKF_CMD=%~dp0\libcmd\nkf32.exe
REM set NKF_PECOIN_CMD=%NKF_CMD% -Sw
REM set NKF_PECOOUT_CMD=%NKF_CMD% -Ws


REM --------------------------------------------------
REM ファイルリスト指定
REM --------------------------------------------------
:SELECT_MENU
echo Menu) b:Bookmarks  e:Edit Bookmarks  others:Please Input RootPath
set /p SELECTED_MENU="RootDir>"
REM echo %SELECTED_MENU%
REM pause
if "%SELECTED_MENU%"=="e" (
    REM ディレクトリリストを編集
    set PECO_DIRLIST=%PECO_BOOKMARK%
    goto :EDIT_BOOKMARK
) else if "%SELECTED_MENU%"=="b" (
    REM 登録しておいたディレクトリリストからルートディレクトリを選択
    set PECO_DIRLIST=%PECO_BOOKMARK%
    call :SELECT_DIR PECO_ROOT_DIR
) else (
    REM 指定のディレクトリ配下から選択
    set PECO_ROOT_DIR=%SELECTED_MENU%
    if not "!PECO_ROOT_DIR!"=="" (
        if not exist "!PECO_ROOT_DIR!" (
            echo NotFound:!PECO_ROOT_DIR!
            goto :EXIT_PROC
        )
    ) else (
        set PECO_ROOT_DIR=%PECO_DEFAULT_ROOT_DIR%
    )
)

REM 指定のルートディレクトリ配下をpecoで選択
REM echo "Goto>%PECO_ROOT_DIR%"
set PECO_DIRLIST=%PECO_TEMPLIST%
dir /s /b /ad "%PECO_ROOT_DIR%" >"%PECO_DIRLIST%"
call :SELECT_DIR PECO_ROOT_DIR
if not "%PECO_ROOT_DIR%"=="" (
    echo GoTo:%PECO_ROOT_DIR%
    call :GOTO_DIR %PECO_ROOT_DIR%
    timeout 3
)
goto :EXIT_PROC

REM --------------------------------------------------
REM ディレクトリリストを編集
REM --------------------------------------------------
:EDIT_BOOKMARK
if not "%EDITOR%"=="" (
    "%EDITOR%" "%PECO_DIRLIST%"
    goto :EXIT_PROC
) else (
    notepad "%PECO_DIRLIST%"
)
goto :EXIT_PROC

REM --------------------------------------------------
REM pecoでディレクトリを選択
REM --------------------------------------------------
:SELECT_DIR
set %1=
for /f "tokens=*" %%a in ('find /N /V "" ^< ^"%PECO_DIRLIST%^" ^| %PECO_CMD%') do (
    cls
    REM findコマンドで出した行番号を削除したパスを取り出す
    call :RemoveLeftToChar %%a ] %1
    REM echo %1:!%1!
)
exit /b

REM --------------------------------------------------
REM ディレクトリを開く
REM --------------------------------------------------
:GOTO_DIR
start explorer /root,"%~1"
exit /b

REM --------------------------------------------------
REM 処理終了
REM --------------------------------------------------
:EXIT_PROC
endlocal
REM chcp 932 >nul    
REM del %PECO_TEMPLIST% >nul 2>&1
exit 

REM --------------------------------------------------
REM 共通処理
REM --------------------------------------------------
REM 指定文字列から指定文字が出現した後の文字列を第3引数にセット
:RemoveLeftToChar
set _text=%~1
Call :GetFirstCharPos %_text% %2 _pos
set /a _pos=_pos+1
set %3=!_text:~%_pos%!
set _text=
set _pos=
exit /b

REM 指定文字列から指定の文字が最初に出現する位置を第3引数にセット
:GetFirstCharPos
set _s=%~1
set _n=-1
set %3=-1
:GetFirstCharPosLoop
set _c=%_s:~0,1%
if not "%_s%"=="" (
    set /a _n=_n+1
    REM echo !n!: !c! vs %~2
    if "%_c%"=="%~2" (
        set /a %3=!_n!
        goto :GetFirstCharPosExit
    )
    set _s=%_s:~1%
    goto :GetFirstCharPosLoop
)
:GetFirstCharPosExit
exit /b
