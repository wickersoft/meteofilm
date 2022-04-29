#include <Wickersoft_HTTP.au3>
#include <Array.au3>
#include <GDIPlus.au3>
#include <Misc.au3>
#include <Memory.au3>
#include <Process.au3>
#include <Array.au3>
#include <Date.au3>
#include "meteo.au3"

_GDIPlus_Startup()
Global Const $FONT_BOLD = 1
global Const $ZOOM_LEVEL = 5
$json = getWetterOnlineMetadata("Last48h")
$array = sliceWetteronlineMetadata($json)

For $metaslice In $array
    $timestamp = getTimestampForMetaslice($metaslice)
    
    $cloudsTimepath = getCloudTimepathEurope($metaslice)
	;_ArrayDisplay($cloudsTimepath)
    
	$cloudsTimepathGlobal = getCloudTimepathGlobal($metaslice)
	;_ArrayDisplay($cloudsTimepathGlobal)
    ConsoleWrite($timestamp & "  :  " & generateTimepathString($cloudsTimepathGlobal, "6") & "   :   " & generateTimepathString($cloudsTimepath, "6") &  @CRLF)
Next

Exit

If 0 Then
    $defaultIndex = getDefaultIndex($json)
    $metaslice = $array[$defaultIndex]
	ConsoleWrite("meeeee: " & $metaslice & @CRLF)
    $timestamp = StringMid($metaslice, 2, 15);
	$rainTimepath = getRainTimepathEurope($metaslice)
	;_ArrayDisplay($rainTimepath)

	$rainTimepathGlobal = getRainTimepathGlobal($metaslice)
	;_ArrayDisplay($rainTimepathGlobal)

	$cloudsTimepath = getCloudTimepathEurope($metaslice)
	;_ArrayDisplay($cloudsTimepath)

	$cloudsTimepathGlobal = getCloudTimepathGlobal($metaslice)
	;_ArrayDisplay($cloudsTimepathGlobal)

	$lightningTimepath = getLightningTimepathEurope($metaslice)
	;_ArrayDisplay($lightningTimepath)

	$lightningTimepathGlobal = getLightningTimepathGlobal($metaslice)
	;_ArrayDisplay($lightningTimepathGlobal)

	$cityTimepathGlobal = getCityTimepathGlobal($metaslice)
	;_ArrayDisplay($cityTimepathGlobal)

	;_ArrayDisplay($cloudsTimepathGlobal)

	;$ctgv = Number(stringmid($cloudsTimepathGlobal[6], 2))
	;$cloudsTimepathGlobal[6] = "v" & ($ctgv + 1)

	;_ArrayDisplay($cloudsTimepathGlobal)
$tile = getWeatherTile(tileCoordsOf(32, 18, 6), $timestamp, $rainTimepath, $rainTimepathGlobal, $cloudsTimepath, $cloudsTimepathGlobal, $lightningTimepath, $lightningTimepathGlobal, $cityTimepathGlobal)
$h = FileOpen(@DesktopDir & "\meteo1.png", 18)
filewrite($h, $tile)
FileClose($H)

Exit
EndIf

DirCreate("meteofilm")

For $i = 0 To UBound($array) - 10
    $metaslice = $array[$i]
	$timestamp = getTimestampForMetaslice($metaslice)
	If FileExists("meteofilm\" & $timestamp & ".png") Then ContinueLoop
	ConsoleWrite($timestamp & @CRLF)
	$data = getHDWeatherMap($metaslice)
	$img = drawLabelContent(3840, 3072, $data, $timestamp)
	$hf = FileOpen("meteofilm\" & $timestamp & ".png", 18)
	FileWrite($hf, $img)
	FileClose($hf)
Next

Func drawLabelContent($iwidth, $iheight, $data, $timestamp)
	$hBitmap = _WinAPI_CreateBitmap($iwidth, $iheight, 1, 32)
	$himage = _GDIPlus_BitmapCreateFromHBITMAP($hBitmap)
	$hGraphic = _GDIPlus_ImageGetGraphicsContext($himage)
	$hWhiteBrush = _GDIPlus_BrushCreateSolid(0xFFFFFFFF)
	$hBlackBrush = _GDIPlus_BrushCreateSolid(0xFF000000)
	$hRedBrush = _GDIPlus_BrushCreateSolid(0xFFFF0000)
	_GDIPlus_GraphicsFillRect($hGraphic, 0, 0, $iwidth, $iheight, $hWhiteBrush)


    $offset_x = 0
    $offset_y = 0
    
    For $y_tile = 0 To 5
        For $x_tile = 0 To 7
            $hTile = imageFromFileBinary($data[8*$y_tile + $x_tile])
            _GDIPlus_GraphicsDrawImageRectRect($hGraphic, $hTile, 0, 0, 512, 512, $offset_x + 512 * $x_tile, $offset_y + 512 * $y_tile, 512, 512)
			_GDIPlus_ImageDispose($hTile)
        Next
    Next
    _GDIPlus_GraphicsDrawStringExEx($hGraphic, $timestamp,  0, 0, 510, 512, $hBlackBrush, "Comic Sans MS", 14, $FONT_BOLD)
	    
	$sImgCLSID = _GDIPlus_EncodersGetCLSID("PNG")
	$tGUID = _WinAPI_GUIDFromString($sImgCLSID)
	$pStream = _WinAPI_CreateStreamOnHGlobal() ;create stream
	;_GDIPlus_ImageSaveToFile($hImage, @DesktopDir & "\debug.png")
	_GDIPlus_ImageSaveToStream($himage, $pStream, DllStructGetPtr($tGUID)) ;save the bitmap in PNG format in memory
	$hData = _WinAPI_GetHGlobalFromStream($pStream)
	$iMemSize = _MemGlobalSize($hData)
	$pData = _MemGlobalLock($hData)
	$tData = DllStructCreate('byte[' & $iMemSize & ']', $pData)
	$bData = DllStructGetData($tData, 1)
	_GDIPlus_GraphicsDispose($hGraphic)
	_GDIPlus_ImageDispose($himage)
	_WinAPI_DeleteObject($hBitmap)
	_WinAPI_ReleaseStream($pStream) ;http://msdn.microsoft.com/en-us/library/windows/desktop/ms221473(v=vs.85).aspx
	_MemGlobalFree($hData)
	Return $bData
EndFunc   ;==>drawLabelContent

Func _GDIPlus_GraphicsDrawStringExEx($hGraphic, $sString, $iX0, $iY0, $iX1, $iY1, $hBrush, $sFont = "Arial", $iFontSize = 12, $iFontStyle = 0)
	$hFormat = _GDIPlus_StringFormatCreate()
	$hFamily = _GDIPlus_FontFamilyCreate($sFont)
	$hFont = _GDIPlus_FontCreate($hFamily, $iFontSize, $iFontStyle)
	$tLayout = _GDIPlus_RectFCreate($iX0, $iY0, $iX1, $iY1)

	_GDIPlus_GraphicsDrawStringEx($hGraphic, $sString, $hFont, $tLayout, $hFormat, $hBrush)

	_GDIPlus_FontDispose($hFont)
	_GDIPlus_FontFamilyDispose($hFamily)
	_GDIPlus_StringFormatDispose($hFormat)
EndFunc   ;==>_GDIPlus_GraphicsDrawStringExEx

Func imageFromFileBinary($binary)
	$iLength = BinaryLen($binary)
    ConsoleWrite("Length: " & $iLength & @CRLF)
	$hData = _MemGlobalAlloc($iLength, $GMEM_MOVEABLE)
	$pData = _MemGlobalLock($hData)
	$tData = DllStructCreate('byte[' & $iLength & ']', $pData)
	DllStructSetData($tData, 1, $binary)
	_MemGlobalUnlock($hData)
	$pStream = _WinAPI_CreateStreamOnHGlobal($hData)
	$hImageFromStream = _GDIPlus_ImageLoadFromStream($pStream)
	_WinAPI_ReleaseStream($pStream)
	Return $hImageFromStream
EndFunc   ;==>imageFromFileBinary

