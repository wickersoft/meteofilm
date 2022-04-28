#include-once
#include <WinHTTP.au3>
#include <WinAPI.au3>

Global $hSession = _WinHTTPOpen()
Global $Wi_ReadBufferSize = 16000000

Func _http($Domain_Name, $URI = "", $content = "", $http_cookies = "", $Additional_Header = "")
	Local $HTTP_Header, $Received_Content, $Content_Length, $Received_Piece, $Previous_Size, $Content_Type = "application/x-www-form-urlencoded"
	Dim $Return[2]
	Dim $aReceived_Content[2]
	$init = TimerInit()
	If StringInStr($Domain_Name, ":") Then
		$Domain_Name = StringSplit($Domain_Name, ":")
		$Port = $Domain_Name[2]
		$Domain_Name = $Domain_Name[1]
	Else
		$Port = 80
	EndIf
	Local $retr = ""

	If $content <> "" Then
		$hConnect = _WinHttpConnect($hSession, $Domain_Name, $Port)
		If @error Then
			$Return[1] = "Connection refused"
			Return $Return
		EndIf
		$hRequest = _WinHTTPOpenRequest($hConnect, "POST", $URI, Default, Default, Default, 0x40)

		$sHeader = "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" & @CRLF & _
				"User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:33.0) Gecko/20100101 Firefox/33.0" & @CRLF & _
				$Additional_Header
		If $http_cookies <> "" Then $sHeader &= @CRLF & "Cookie: " & $http_cookies
		_WinHttpSendRequest($hRequest, $sHeader, $content)
		If @error Then
			$Return[1] = "Connection refused"
			Return $Return
		EndIf
		_WinHttpReceiveResponse($hRequest)
		If @error Then
			$Return[1] = "Connection refused"
			Return $Return
		EndIf
		$headers = _WinHttpQueryHeaders($hRequest)
		$Received_Content = Binary("")
		Do
			$Received_Content &= _WinHttpReadData($hRequest, 2, $Wi_ReadBufferSize)
		Until @error
	Else
		$hConnect = _WinHttpConnect($hSession, $Domain_Name, $Port)
		If @error Then
			$Return[1] = "Connection refused"
			Return $Return
		EndIf
		$hRequest = _WinHTTPOpenRequest($hConnect, "GET", $URI, Default, Default, Default, 0x40)
		$sHeader = "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" & @CRLF & _
				"User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:33.0) Gecko/20100101 Firefox/33.0" & @CRLF & _
				$Additional_Header
		If $http_cookies <> "" Then $sHeader &= @CRLF & "Cookie: " & $http_cookies
		_WinHttpSendRequest($hRequest, $sHeader)
		If @error Then
			$Return[1] = "Connection refused"
			Return $Return
		EndIf
		_WinHttpReceiveResponse($hRequest)
		If @error Then
			$Return[1] = "Connection refused"
			Return $Return
		EndIf
		$headers = _WinHttpQueryHeaders($hRequest)
		$Received_Content = Binary("")
		Do
			$Received_Content &= _WinHttpReadData($hRequest, 2, $Wi_ReadBufferSize)
		Until @error
	EndIf
	$Return[0] = $Received_Content
	$Return[1] = $headers
	Return $Return
EndFunc   ;==>_http

Func _https($Domain_Name, $URI = "", $content = "", $http_cookies = "", $Additional_Header = "")
	Local $HTTP_Header, $Received_Content, $Content_Length, $Received_Piece, $Previous_Size, $Content_Type = "application/x-www-form-urlencoded"
	Dim $Return[2]
	Dim $aReceived_Content[2]
	$init = TimerInit()
	If StringInStr($Domain_Name, ":") Then
		$Domain_Name = StringSplit($Domain_Name, ":")
		$Port = $Domain_Name[2]
		$Domain_Name = $Domain_Name[1]
	Else
		$Port = 443
	EndIf
	Local $retr = ""

	If $content <> "" Then
		$hConnect = _WinHttpConnect($hSession, $Domain_Name, $Port)
		If @error Then
			$Return[1] = "Connection refused 0"
			Return $Return
		EndIf
		$hRequest = _WinHTTPOpenRequest($hConnect, "POST", $URI, Default, Default, Default, 0x800040)
		$sHeader = "Content-Type: application/x-www-form-urlencoded" & @CRLF & _
				"User-Agent: Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36" & @CRLF & _
				"Content-Length: " & BinaryLen($content)
		If $http_cookies <> "" Then $sHeader &= @CRLF & "Cookie: " & $http_cookies
		If $Additional_Header <> "" Then $sHeader &= @CRLF & $Additional_Header
		_WinHttpSendRequest($hRequest, $sHeader, $content)
		If @error Then
			$Return[1] = "Connection refused 1"
			Return $Return
		EndIf
		_WinHttpReceiveResponse($hRequest)
		If @error Then
			$Return[1] = "Connection refused 2"
			Return $Return
		EndIf
		$headers = _WinHttpQueryHeaders($hRequest)
		$Received_Content = _WinHttpReadData($hRequest, 2, $Wi_ReadBufferSize)
	Else
		$hConnect = _WinHttpConnect($hSession, $Domain_Name, $Port)
		If @error Then
			$Return[1] = "Connection refused 3"
			Return $Return
		EndIf
		$hRequest = _WinHTTPOpenRequest($hConnect, "GET", $URI, Default, Default, Default, 0x800040)
		$sHeader = "User-Agent: Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36" & @CRLF & _
				$Additional_Header
		If $http_cookies <> "" Then $sHeader &= @CRLF & "Cookie: " & $http_cookies
		_WinHttpSendRequest($hRequest, $sHeader)
		If @error Then
			$Return[1] = "Connection refused 4"
			Return $Return
		EndIf
		_WinHttpReceiveResponse($hRequest)
		If @error Then
			$Return[1] = "Connection refused 5"
			Return $Return
		EndIf
		$headers = _WinHttpQueryHeaders($hRequest)
		$Received_Content = _WinHttpReadData($hRequest, 2, $Wi_ReadBufferSize)
	EndIf
	$Return[0] = $Received_Content
	$Return[1] = $headers
	Return $Return
EndFunc   ;==>_https

Func _http_fast($Domain_Name, $URI = "", $content = "", $http_cookies = "", $Additional_Header = "")
	Local $HTTP_Header, $Received_Content, $Content_Length, $Received_Piece, $Previous_Size, $Content_Type = "application/x-www-form-urlencoded"
	$init = TimerInit()
	If StringInStr($Domain_Name, ":") Then
		$Domain_Name = StringSplit($Domain_Name, ":")
		$Port = $Domain_Name[2]
		$Domain_Name = $Domain_Name[1]
	Else
		$Port = 80
	EndIf
	$Domain_Name = TCPNameToIP($Domain_Name)
	Local $retr = ""

	If $content <> "" Then
		$sock = TCPConnect($Domain_Name, $Port)
		If @error Then Return 0

		$sHeader = "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" & @CRLF & _
				"Host: " & $Domain_Name & @CRLF & _
				"Content-Length: " & BinaryLen($content) & @CRLF & _
				$Additional_Header
		TCPSend($sock, "POST " & $URI & " HTTP/1.1" & @CRLF & _
				$sHeader & @CRLF & _
				$content)
	Else
		$sock = TCPConnect($Domain_Name, $Port)
		If @error Then Return 0

		$sHeader = "Host: " & $Domain_Name & @CRLF & _
				$Additional_Header
		TCPSend($sock, "GET " & $URI & " HTTP/1.1" & @CRLF & _
				$sHeader & @CRLF)
	EndIf
	Return 1
EndFunc   ;==>_http_fast

Func _http_header_disassemble($HTTP_Header)
	$HTTP_Header = StringSplit($HTTP_Header, @CRLF, 1)
	Dim $lines[$HTTP_Header[0] - 1][2]
	$lines[0][0] = $HTTP_Header[0] - 2
	For $i = 1 To $lines[0][0]
		$Delimiter = StringInStr($HTTP_Header[$i], " ")
		If $Delimiter Then
			$lines[$i][0] = StringLeft($HTTP_Header[$i], $Delimiter - 1)
			$lines[$i][1] = StringMid($HTTP_Header[$i], $Delimiter + 1)
		EndIf
	Next
	Return $lines
EndFunc   ;==>_http_header_disassemble

Func _http_header_getvalue(ByRef $HTTP_Header, $Variable_Name)
	For $i = 1 To $HTTP_Header[0][0]
		If $HTTP_Header[$i][0] = $Variable_Name Then Return $HTTP_Header[$i][1]
	Next
	Return -1
EndFunc   ;==>_http_header_getvalue

Func _BOM_Remove(ByRef $string)
	If StringLeft($string, 3) = BinaryToString(0xBFBBEF) Then $string = StringTrimLeft($string, 3)
	Return $string
EndFunc   ;==>_BOM_Remove

Func _httpSetReadBufferSize($size = 262144)
	$Wi_ReadBufferSize = $size
EndFunc

Func stringextract($string, $start, $end, $offset = 1)
	If $start = "" Then
		$left_bound = $offset
	Else
		$left_bound = StringInStr($string, $start, 0, 1, $offset)
	EndIf
	If $left_bound = 0 Then Return SetExtended(-1, "")
	$left_bound += StringLen($start)
	If $end = "" Then
		$right_bound = StringLen($string) + 1
	Else
		$right_bound = StringInStr($string, $end, 0, 1, $left_bound)
	EndIf
	If $right_bound = 0 Then Return SetExtended(-1, "")
	Return SetExtended($left_bound, StringMid($string, $left_bound, $right_bound - $left_bound))
EndFunc   ;==>stringextract

Func stringextractall($string, $start, $end)
	$offset = 1
	Dim $results[0]
	While 1
		$str = stringextract($string, $start, $end, $offset)
		If @extended = -1 Then Return $results
		$offset = @extended + StringLen($str) + StringLen($end)
		ReDim $results[UBound($results) + 1]
		$results[UBound($results) - 1] = $str
	WEnd
EndFunc   ;==>stringextractall


Func binaryappend($bin_a, $bin_b)
	$len = BinaryLen($bin_a) + BinaryLen($bin_b)
	$offset = BinaryLen($bin_a)
	$ptr = $offset + 1
	$struct = DllStructCreate("byte[" & $len & "]")
	DllStructSetData($struct, 1, $bin_a)
	While $ptr <= $len
		DllStructSetData($struct, 1, BinaryMid($bin_b, $ptr - $offset, 1), $ptr)
		$ptr += 1
	WEnd
	$bin_c = DllStructGetData($struct, 1)
	$struct = 0
	Return $bin_c
EndFunc   ;==>binaryappend


; =========================================================== WebSocket Functions ==================================================================

Global Const $ERROR_NOT_ENOUGH_MEMORY = 8
Global Const $ERROR_INVALID_PARAMETER = 87

Global Const $WINHTTP_OPTION_UPGRADE_TO_WEB_SOCKET = 114

Global Const $WINHTTP_WEB_SOCKET_BINARY_MESSAGE_BUFFER_TYPE = 0
Global Const $WINHTTP_WEB_SOCKET_BINARY_FRAGMENT_BUFFER_TYPE = 1

Global Const $WINHTTP_WEB_SOCKET_SUCCESS_CLOSE_STATUS = 1000


Func _WebSocketOpen($sServerName, $iPort = 80, $sPath = "", $bWebSocketSecure = False)
	$WINHTTP_OPEN_REQUEST_FLAGS = 0x40
	If $bWebSocketSecure Then $WINHTTP_OPEN_REQUEST_FLAGS = BitOR($WINHTTP_OPEN_REQUEST_FLAGS, 0x800000)

	; Create session, connection and request handles.
	$hOpen = _WinHttpOpen("WebSocket sample", $WINHTTP_ACCESS_TYPE_DEFAULT_PROXY)
	If $hOpen = 0 Then
		$iError = _WinAPI_GetLastError()
		ConsoleWrite("Open error" & @CRLF)
		Return False
	EndIf

	$hConnect = _WinHttpConnect($hOpen, $sServerName, $iPort)
	If $hConnect = 0 Then
		$iError = _WinAPI_GetLastError()
		ConsoleWrite("Connect error" & @CRLF)
		Return False
	EndIf

	$hRequest = _WinHttpOpenRequest($hConnect, "GET", $sPath, Default, Default, Default, $WINHTTP_OPEN_REQUEST_FLAGS)
	If $hRequest = 0 Then
		$iError = _WinAPI_GetLastError()
		ConsoleWrite("OpenRequest error" & @CRLF)
		Return False
	EndIf

	; Request protocol upgrade from http to websocket.

	Local $fStatus = _WinHttpSetOptionNoParams($hRequest, $WINHTTP_OPTION_UPGRADE_TO_WEB_SOCKET)
	If Not $fStatus Then
		$iError = _WinAPI_GetLastError()
		ConsoleWrite("SetOption error" & @CRLF)
		Return False
	EndIf

	; Perform websocket handshake by sending a request and receiving server's response.
	; Application may specify additional headers if needed.

	$fStatus = _WinHttpSendRequest($hRequest)
	If Not $fStatus Then
		$iError = _WinAPI_GetLastError()
		ConsoleWrite("SendRequest error" & @CRLF)
		Return False
	EndIf

	$fStatus = _WinHttpReceiveResponse($hRequest)
	If Not $fStatus Then
		$iError = _WinAPI_GetLastError()
		ConsoleWrite("SendRequest error" & @CRLF)
		Return False
	EndIf

	; Application should check what is the HTTP status code returned by the server and behave accordingly.
	; WinHttpWebSocketCompleteUpgrade will fail if the HTTP status code is different than 101.

	$hWebSocket = _WinHttpWebSocketCompleteUpgrade($hRequest, 0)
	If $hWebSocket = 0 Then
		$iError = _WinAPI_GetLastError()
		ConsoleWrite("WebSocketCompleteUpgrade error" & @CRLF)
		Return False
	EndIf

	_WinHttpCloseHandle($hRequest)
	$hRequestHandle = 0

	Return $hWebSocket
EndFunc   ;==>_WebSocketOpen

Func _WebSocketSend($hWebSocket, $bMessage, $iWebSocketBufferType = 0)
	; Send data on the websocket protocol.
	$iError = _WinHttpWebSocketSend($hWebSocket, _
			$iWebSocketBufferType, _
			$bMessage)
	If @error Or $iError <> 0 Then
		ConsoleWrite("WebSocketSend error" & @CRLF)
		Return False
	EndIf
EndFunc   ;==>_WebSocketSend

Func _WebSocketRecv($hWebSocket, $iBufferLen, $bWaitForData = False)
	Local $tBuffer = 0, $bRecv = Binary("")

	Local $iBytesRead = 0, $iBufferType = 0

	If $iBufferLen = 0 Then
		$iError = $ERROR_NOT_ENOUGH_MEMORY
		Return False
	EndIf

	Do
		$tBuffer = DllStructCreate("byte[" & $iBufferLen & "]")

		$iError = _WinHttpWebSocketReceive($hWebSocket, _
				$tBuffer, _
				$iBytesRead, _
				$iBufferType)
		If @error Or $iError <> 0 Then
			ConsoleWrite("WebSocketReceive error " & @error & " " & $iError & @CRLF)
			Return False
		EndIf

		; If we receive just part of the message restart the receive operation.

		$bRecv &= BinaryMid(DllStructGetData($tBuffer, 1), 1, $iBytesRead)
		$tBuffer = 0

		$iBufferLen -= $iBytesRead
	Until Not $bWaitForData Or $iBufferType <> $WINHTTP_WEB_SOCKET_BINARY_FRAGMENT_BUFFER_TYPE Or $iBufferLen <= 0

	Return SetExtended($iBufferType, $bRecv)
EndFunc   ;==>_WebSocketRecv

Func _WebSocketCloseSocket($hWebSocket)
	; Gracefully close the connection.

	$iError = _WinHttpWebSocketClose($hWebSocket, _
			$WINHTTP_WEB_SOCKET_SUCCESS_CLOSE_STATUS)
	If @error Or $iError <> 0 Then
		ConsoleWrite("WebSocketClose error" & @CRLF)
		Return False
	EndIf

	; Check close status returned by the server.

	Local $iStatus = 0, $iReasonLengthConsumed = 0
	Local $tCloseReasonBuffer = DllStructCreate("byte[1000]")

	$iError = _WinHttpWebSocketQueryCloseStatus($hWebSocket, _
			$iStatus, _
			$iReasonLengthConsumed, _
			$tCloseReasonBuffer)
	If @error Or $iError <> 0 Then
		ConsoleWrite("QueryCloseStatus error" & @CRLF)
		Return False
	EndIf

	ConsoleWrite("The server closed the connection with status code: '" & $iStatus & "' and reason: '" & _
			BinaryToString(BinaryMid(DllStructGetData($tCloseReasonBuffer, 1), 1, $iReasonLengthConsumed)) & "'" & @CRLF)

	Return True
EndFunc   ;==>_WebSocketCloseSocket

Func _WinHttpSetOptionNoParams($hInternet, $iOption)
	Local $aCall = DllCall($hWINHTTPDLL__WINHTTP, "bool", "WinHttpSetOption", _
			"handle", $hInternet, "dword", $iOption, "ptr", 0, "dword", 0)
	If @error Or Not $aCall[0] Then Return SetError(4, 0, 0)
	Return 1
EndFunc   ;==>_WinHttpSetOptionNoParams

Func _WinHttpWebSocketCompleteUpgrade($hRequest, $pContext = 0)
	Local $aCall = DllCall($hWINHTTPDLL__WINHTTP, "handle", "WinHttpWebSocketCompleteUpgrade", _
			"handle", $hRequest, _
			"DWORD_PTR", $pContext)
	If @error Then Return SetError(@error, @extended, -1)
	Return $aCall[0]
EndFunc   ;==>_WinHttpWebSocketCompleteUpgrade

Func _WinHttpWebSocketSend($hWebSocket, $iBufferType, $vData)
	Local $tBuffer = 0, $iBufferLen = 0
	If IsBinary($vData) = 0 Then $vData = StringToBinary($vData, 4)
	$iBufferLen = BinaryLen($vData)
	If $iBufferLen > 0 Then
		$tBuffer = DllStructCreate("byte[" & $iBufferLen & "]")
		DllStructSetData($tBuffer, 1, $vData)
	EndIf

	Local $aCall = DllCall($hWINHTTPDLL__WINHTTP, "DWORD", "WinHttpWebSocketSend", _
			"handle", $hWebSocket, _
			"int", $iBufferType, _
			"ptr", DllStructGetPtr($tBuffer), _
			"DWORD", $iBufferLen)
	If @error Then Return SetError(@error, @extended, -1)
	Return $aCall[0]
EndFunc   ;==>_WinHttpWebSocketSend

Func _WinHttpWebSocketReceive($hWebSocket, $tBuffer, ByRef $iBytesRead, ByRef $iBufferType)
	Local $aCall = DllCall($hWINHTTPDLL__WINHTTP, "handle", "WinHttpWebSocketReceive", _
			"handle", $hWebSocket, _
			"ptr", DllStructGetPtr($tBuffer), _
			"DWORD", DllStructGetSize($tBuffer), _
			"DWORD*", $iBytesRead, _
			"int*", $iBufferType)
	If @error Then Return SetError(@error, @extended, -1)
	$iBytesRead = $aCall[4]
	$iBufferType = $aCall[5]
	Return $aCall[0]
EndFunc   ;==>_WinHttpWebSocketReceive

Func _WinHttpWebSocketClose($hWebSocket, $iStatus, $tReason = 0)
	Local $aCall = DllCall($hWINHTTPDLL__WINHTTP, "handle", "WinHttpWebSocketClose", _
			"handle", $hWebSocket, _
			"USHORT", $iStatus, _
			"ptr", DllStructGetPtr($tReason), _
			"DWORD", DllStructGetSize($tReason))
	If @error Then Return SetError(@error, @extended, -1)
	Return $aCall[0]
EndFunc   ;==>_WinHttpWebSocketClose

Func _WinHttpWebSocketQueryCloseStatus($hWebSocket, ByRef $iStatus, ByRef $iReasonLengthConsumed, $tCloseReasonBuffer = 0)
	Local $aCall = DllCall($hWINHTTPDLL__WINHTTP, "handle", "WinHttpWebSocketQueryCloseStatus", _
			"handle", $hWebSocket, _
			"USHORT*", $iStatus, _
			"ptr", DllStructGetPtr($tCloseReasonBuffer), _
			"DWORD", DllStructGetSize($tCloseReasonBuffer), _
			"DWORD*", $iReasonLengthConsumed)
	If @error Then Return SetError(@error, @extended, -1)
	$iStatus = $aCall[2]
	$iReasonLengthConsumed = $aCall[5]
	Return $aCall[0]
EndFunc   ;==>_WinHttpWebSocketQueryCloseStatus

Func base64($vCode, $bEncode = True, $bUrl = True)
	Local $oDM = ObjCreate("Microsoft.XMLDOM")
	If Not IsObj($oDM) Then Return SetError(1, 0, 1)

	Local $oEL = $oDM.createElement("Tmp")
	$oEL.DataType = "bin.base64"

	If $bEncode Then
		$oEL.NodeTypedValue = Binary($vCode)
		If Not $bUrl Then Return $oEL.Text
		Return StringReplace($oEL.Text, @LF, "")
	Else
		If $bUrl Then $vCode = StringReplace(StringReplace($vCode, "-", "+"), "_", "/")
		$oEL.Text = $vCode
		Return $oEL.NodeTypedValue
	EndIf

EndFunc   ;==>base64