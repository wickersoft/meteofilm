#include "Wickersoft_HTTP.au3"
#include "Array.au3"

Func getRainMap($json, $timestamp = "")
	Dim $tiles[4]
	$tiles[0] = getRainTile($json, "6_4", $timestamp)
	$tiles[1] = getRainTile($json, "8_4", $timestamp)
	$tiles[2] = getRainTile($json, "6_6", $timestamp)
	$tiles[3] = getRainTile($json, "8_6", $timestamp)
	Return $tiles
EndFunc   ;==>getRainMap

Func getRainTile($json, $tile_id, $timestamp = "")
	$url = getRainTileUrl($json, $tile_id, $timestamp)
	;clipput($url)
	$tile = InetRead($url, 9)
	Return $tile
EndFunc   ;==>getRainTile

Func getRainTileUrl($json, $tile_id, $timestamp, $zoomlevel = "4")
	$latest = getMetadataForTimestamp($json, $timestamp)
	ConsoleWrite("metadata: " & $latest & @CRLF)
	;_arraydisplay($array)

	$rainTimepath = getRainTimepathEurope($latest)
	;_ArrayDisplay($rainTimepath)

	$rainTimepathGlobal = getRainTimepathGlobal($latest)
	;_ArrayDisplay($rainTimepathGlobal)


	$tiles64 = generateTilesString($tile_id, $zoomlevel, $rainTimepath, $rainTimepathGlobal)
	$url = "https://tiles.wo-cloud.com/composite?format=png&lg=rr&tiles=" & $tiles64
	If $timestamp <> "" Then $url &= "&time=" & $timestamp
	Return $url
EndFunc   ;==>getRainTileUrl

Func getHDWeatherMap($json, $timestamp = "")
	Dim $tiles[48]
    
    $metaslice = getMetadataForTimestamp($json, $timestamp)
	ConsoleWrite("meeeee: " & $metaslice & @CRLF)

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
    
    
    For $y_tile = 0 To 5
        For $x_tile = 0 To 7
            $tiles[8*$y_tile + $x_tile] = getWeatherTile(tileCoordsOf(24 + 2 * $x_tile, 16 + 2 * $y_tile, 6), $timestamp, $rainTimepath, $rainTimepathGlobal, $cloudsTimepath, $cloudsTimepathGlobal, $lightningTimepath, $lightningTimepathGlobal, $cityTimepathGlobal)
        Next
    Next
	Return $tiles
EndFunc   ;==>getHDWeatherMap

Func getWeatherTile($tile_coords, $timestamp, $rainTimepath, $rainTimepathGlobal, $cloudsTimepath, $cloudsTimepathGlobal, $lightningTimepath, $lightningTimepathGlobal, $cityTimepathGlobal)
	$url = getWeatherTileUrl($tile_coords, $timestamp, $rainTimepath, $rainTimepathGlobal, $cloudsTimepath, $cloudsTimepathGlobal, $lightningTimepath, $lightningTimepathGlobal, $cityTimepathGlobal)
	ConsoleWrite("Weather url: " & $url & @CRLF)
	$tile = InetRead($url, 9)
	Return $tile
EndFunc   ;==>getWeatherTile

Func getWeatherTileUrl($tile_coords, $timestamp, $rainTimepath, $rainTimepathGlobal, $cloudsTimepath, $cloudsTimepathGlobal, $lightningTimepath, $lightningTimepathGlobal, $cityTimepathGlobal)
	$tiles64 = generateTilesString3($tile_coords, $rainTimepath, $rainTimepathGlobal, $cloudsTimepath, $cloudsTimepathGlobal, $lightningTimepath, $lightningTimepathGlobal, $cityTimepathGlobal)
	$url = "https://tiles.wo-cloud.com/composite?format=png&lg=wr&tiles=" & $tiles64
	If $timestamp <> "" Then $url &= "&time=" & $timestamp
	Return $url
EndFunc   ;==>getWeatherTileUrl

Func getWetterOnlineMetadata($periodLast = "Last6h")
	$http = _https("tiles.wo-cloud.com", "metadata?lg=wr&period=period" & $periodLast & "&type=period")
	$json = BinaryToString($http[0])
	Return $json
EndFunc   ;==>getWetterOnlineMetadata

Func getAllAvailableTimestamps($json)
	Return stringextractall($json, '{"id": "', '"')
EndFunc   ;==>getAllAvailableTimestamps

Func getMetadataForTimestamp($json, $timestamp = "")
	$defaultindex = Number(stringextract($json, '"defaultIndex": "', '"'))
	$array = stringextractall($json, '{"id": ', '}}}}')

	If $timestamp = "" Then
		Return $array[$defaultindex]
	Else
		For $line In $array
			If StringMid($line, 2, 15) = $timestamp Then Return $line
		Next
	EndIf
EndFunc   ;==>getMetadataForTimestamp

Func getRainTimepathEurope($metaslice)
	Return gettimepathEurope($metaslice, "rain", "},")
EndFunc   ;==>getRainTimepathEurope

Func getRainTimepathGlobal($metaslice)
	Return getTimepathGlobal($metaslice, "rain", "},")
EndFunc   ;==>getRainTimepathGlobal

Func getCloudTimepathEurope($metaslice)
	Return gettimepathEurope($metaslice, "clouds", "},")
EndFunc   ;==>getCloudTimepathEurope

Func getCloudTimepathGlobal($metaslice)
	Return getTimepathGlobal($metaslice, "clouds", "},")
EndFunc   ;==>getCloudTimepathGlobal

Func getLightningTimepathEurope($metaslice)
	Return gettimepathEurope($metaslice, "lightning", "},")
EndFunc   ;==>getLightningTimepathEurope

Func getLightningTimepathGlobal($metaslice)
	Return getTimepathGlobal($metaslice, "lightning", "},")
EndFunc   ;==>getLightningTimepathGlobal

Func getCityTimepathGlobal($metaslice)
	Return getTimepathGlobal($metaslice, "cityWeatherData", "},")
EndFunc   ;==>getCityTimepathGlobal

Func gettimepathEurope($metaslice, $layerstart, $layerend)
	Return getTimepath($metaslice, "europe", "}},", $layerstart, $layerend)
EndFunc   ;==>gettimepathEurope

Func getTimepathGlobal($metaslice, $layerstart, $layerend)
	Return getTimepath($metaslice, "global", "}},", $layerstart, $layerend)
EndFunc   ;==>getTimepathGlobal

Func getTimepath($metaslice, $regionstart, $regionend, $layerstart, $layerend)
	$layer = stringextract($metaslice, '"' & $regionstart & '"', $regionend)
	$layer = stringextract($layer, '"' & $layerstart & '"', $layerend)
	$timepath = stringextract($layer, '"timePath": [', ']')
	Dim $r[1] = [stringextract($layer, '"path": "', '"')]
	$date = stringextractall($timepath, '"', '"')
	_ArrayAdd($r, $date)
	$maxZoomlevel = stringextract($layer, '"mnz": ', '')
	_ArrayAdd($r, $maxZoomlevel)
	Return $r
EndFunc   ;==>getTimepath

Func generateTilesString($tile_id, $zoomlevel, $rainTimepath, $rainTimepathGlobal)
	$tilesString = "topo|1;;0;0|wetterradar/prozess/tiles/geolayer/rasterimages/rr_topography/v1/ZL" & $zoomlevel & "/512/" & $tile_id & ".png$r|1;;0;0;false|" & _
			"wetterradar/prozess/tiles/" & _ArrayToString($rainTimepath, "/", 0, 6) & "/ZL" & $zoomlevel & "/512/sprite/" & $tile_id & ".png;" & _
			"wetterradarglobal/prozess/tiles/" & _ArrayToString($rainTimepathGlobal, "/", 0, 6) & "/ZL" & $zoomlevel & "/512/border/" & $tile_id & ".png$i|" & _
			"1;;0;0|geo/prozess/karten/produktkarten/wetterradar/generate/rasterTiles/rr_geooverlay_cities_excluded/v2/ZL" & $zoomlevel & "/512/" & $tile_id & ".png"
	ConsoleWrite($tilesString & @CRLF)
	$tiles64 = base64($tilesString)
	Return $tiles64
EndFunc   ;==>generateTilesString

Func generateTilesString2($tile_id, $zoomlevel, $rainTimepath, $rainTimepathGlobal, $cloudsTimepath, $cloudsTimepathGlobal, $lightningTimepath, $lightningTimepathGlobal, $cityTimepathGlobal)
	$tilesString = "topo|1;;0;0|" & _
			"wetterradar/prozess/tiles/geolayer/rasterimages/wr_topography/v1/ZL" & $zoomlevel & "/512/" & $tile_id & ".png$a|1;;0;0|" & _
			"wetterradarglobal/prozess/tiles/" & _ArrayToString($cityTimepathGlobal, "/") & "/ZL" & $zoomlevel & "/512/" & $tile_id & ".txt$c|1;;0;0;false|" & _
			"wetterradar/prozess/tiles/" & _ArrayToString($cloudsTimepath, "/") & "/ZL" & $zoomlevel & "/512/" & $tile_id & ".png;" & _
			"wetterradarglobal/prozess/tiles/" & _ArrayToString($cloudsTimepathGlobal, "/") & "/ZL" & $zoomlevel & "/512/border/" & $tile_id & ".png$r|1;;0;0;false|" & _
			"wetterradar/prozess/tiles/" & _ArrayToString($rainTimepath, "/") & "/ZL" & $zoomlevel & "/512/sprite/" & $tile_id & ".png;" & _
			"wetterradarglobal/prozess/tiles/" & _ArrayToString($rainTimepathGlobal, "/") & "/ZL" & $zoomlevel & "/512/border/" & $tile_id & ".png$s|1;;0;0;false|" & _
			"wetterradar/prozess/tiles/" & _ArrayToString($rainTimepath, "/") & "/ZL" & $zoomlevel & "/512/flakes/" & $tile_id & ".txt;" & _
			"wetterradarglobal/prozess/tiles/" & _ArrayToString($rainTimepathGlobal, "/") & "/ZL" & $zoomlevel & "/512/borderFlakes/" & $tile_id & ".txt$i|1;;0;0|" & _
			"wetterradar/prozess/tiles/geolayer/rasterimages/wr_geooverlay/v2/ZL" & $zoomlevel & "/512/" & $tile_id & ".png$t|1;;0;0|" & _
			"wetterradarglobal/prozess/tiles/" & _ArrayToString($cityTimepathGlobal, "/") & "/ZL" & $zoomlevel & "/512/" & $tile_id & ".txt$l|1;;0;0;false|" & _
			"wetterradarglobal/prozess/tiles/" & _ArrayToString($lightningTimepath, "/") & "/ZL" & $zoomlevel & "/512/" & $tile_id & ".png;" & _
			"wetterradarglobal/prozess/tiles/" & _ArrayToString($lightningTimepathGlobal, "/") & "/ZL" & $zoomlevel & "/512/border/" & $tile_id & ".png"

	#cs
	topo|1;;0;0|
	wetterradar/prozess/tiles/geolayer/rasterimages/wr_topography/v1/ZL4/512/8_4.png$a|1;;0;0|
	wetterradarglobal/prozess/tiles/cityWeatherData/2022/04/24/09/00/v23/ZL4/512/8_4.txt$c|1;;0;0;false|
	wetterradar/prozess/tiles/satlayerObs/2022/04/24/09/00/v0/ZL4/512/8_4.png;
	 wetterradarglobal/prozess/tiles/satlayerObs/2022/04/24/09/00/v1/ZL4/512/border/8_4.png$r|1;;0;0;false|
	wetterradar/prozess/tiles/rainlayerObs/2022/04/24/09/00/v1/ZL4/512/sprite/8_4.png;
	 wetterradarglobal/prozess/tiles/rainlayerObs/2022/04/24/09/00/v1/ZL4/512/border/8_4.png$s|1;;0;0;false|
	wetterradar/prozess/tiles/rainlayerObs/2022/04/24/09/00/v1/ZL4/512/flakes/8_4.txt;
	 wetterradarglobal/prozess/tiles/rainlayerObs/2022/04/24/09/00/v1/ZL4/512/borderFlakes/8_4.txt$i|1;;0;0|
	wetterradar/prozess/tiles/geolayer/rasterimages/wr_geooverlay/v2/ZL4/512/8_4.png$t|1;;0;0|
	wetterradarglobal/prozess/tiles/cityWeatherData/2022/04/24/09/00/v23/ZL4/512/8_4.txt$l|1;;0;0;false|
	wetterradarglobal/prozess/tiles/lightninglayerObs/2022/04/24/09/00/v3/ZL4/512/8_4.png;
	 wetterradarglobal/prozess/tiles/lightninglayerObs/2022/04/24/09/00/v3/ZL4/512/border/8_4.png
	#ce
	ConsoleWrite($tilesString & @CRLF)
	$tiles64 = base64($tilesString)
	Return $tiles64
EndFunc   ;==>generateTilesString2

Func generateTilesString3($tile_coords, $rainTimepath, $rainTimepathGlobal, $cloudsTimepath, $cloudsTimepathGlobal, $lightningTimepath, $lightningTimepathGlobal, $cityTimepathGlobal)
	$tilesString = "topo|" & _
			generateGeolayerTilestring($tile_coords, $lightningTimepath) & _
			generateCityweatherTilestring($tile_coords, $cityTimepathGlobal) & _
			generateCloudsTilestring($tile_coords, $cloudsTimepath, $cloudsTimepathGlobal) & _
			generateRainTilestring($tile_coords, $rainTimepath, $rainTimepathGlobal) & _
			generateFlakesTilestring($tile_coords, $rainTimepath, $rainTimepathGlobal) & _
			generateGeolayer2Tilestring($tile_coords, $lightningTimepath) & _
			generateCityweather2Tilestring($tile_coords, $cityTimepathGlobal) & _
			generateLightningTilestring($tile_coords, $lightningTimepath, $lightningTimepathGlobal)

	ConsoleWrite($tilesString & @CRLF)
	$tiles64 = base64($tilesString)
	Return $tiles64
EndFunc   ;==>generateTilesString3

Func generateGeolayerTilestring($tile_coords, ByRef $timepath)
    ;$tile_coords = clampTileCoords($tile_coords, $timepath)
	Return "1;;0;0|wetterradar/prozess/tiles/geolayer/rasterimages/wr_topography/v1/ZL" & $tile_coords[2] & "/512/" & $tile_coords[0] & "_" & $tile_coords[1] & ".jpg$a|"
EndFunc   ;==>generateGeolayerTilestring

Func generateGeolayer2Tilestring($tile_coords, ByRef $timepath)
    ;$tile_coords = clampTileCoords($tile_coords, $timepath)
	Return "1;;0;0|wetterradar/prozess/tiles/geolayer/rasterimages/wr_geooverlay/v2/ZL" & $tile_coords[2] & "/512/" & $tile_coords[0] & "_" & $tile_coords[1] & ".png$t|"
EndFunc   ;==>generateGeolayer2Tilestring

Func generateCityweatherTilestring($tile_coords, ByRef $timepath)
	If UBound($timepath) = 2 Then return ""
    ;$tile_coords = clampTileCoords($tile_coords, $timepath)
	If hasLocalTile($tile_coords) Then
		Return "1;;0;0|wetterradarglobal/prozess/tiles/" & generateTimepathString($timepath, $tile_coords[2]) & "/512/" & $tile_coords[0] & "_" & $tile_coords[1] & ".txt$c|"
	Else
		Return "1;;0;0|wetterradarglobal/prozess/tiles/" & generateTimepathString($timepath, $tile_coords[2]) & "/512/" & $tile_coords[0] & "_" & $tile_coords[1] & ".txt$c|"
	EndIf
EndFunc   ;==>generateCityweatherTilestring

Func generateCityweather2Tilestring($tile_coords, ByRef $timepath)
    If UBound($timepath) = 2 Then return ""
    ;$tile_coords = clampTileCoords($tile_coords, $timepath)
	If hasLocalTile($tile_coords) Then
		Return "1;;0;0|wetterradarglobal/prozess/tiles/" & generateTimepathString($timepath, $tile_coords[2]) & "/512/" & $tile_coords[0] & "_" & $tile_coords[1] & ".txt$l|"
	Else
		Return "1;;0;0|wetterradarglobal/prozess/tiles/" & generateTimepathString($timepath, $tile_coords[2]) & "/512/" & $tile_coords[0] & "_" & $tile_coords[1] & ".txt$l|"
	EndIf
EndFunc   ;==>generateCityweather2Tilestring

Func generateCloudsTilestring($tile_coords, ByRef $timepathL, ByRef $timepathG)
	If UBound($timepathG) = 2 Then return ""
    ;$tile_coordsG = clampTileCoords($tile_coords, $timepathG)
	$tilesString = ""
	If hasLocalTile($tile_coords) Then
		;$tile_coordsL = clampTileCoords($tile_coords, $timepathL)
        $tilesString &= "1;;0;0;false|wetterradar/prozess/tiles/" & generateTimepathString($timepathL, $tile_coords[2]) & "/512/" & $tile_coords[0] & "_" & $tile_coords[1] & ".png;"
		$tilesString &= "wetterradarglobal/prozess/tiles/" & generateTimepathString($timepathG, $tile_coords[2]) & "/512/border/" & $tile_coords[0] & "_" & $tile_coords[1] & ".png$r|"
	Else
        $tile_coordsG = factorizeTileCoordinates($tile_coords, $timepathG)
		$tilesString &= $tile_coordsG[3] & "|wetterradarglobal/prozess/tiles/" & generateTimepathString($timepathG, $tile_coordsG[2]) & "/522/" & $tile_coordsG[0] & "_" & $tile_coordsG[1] & ".png$r|"
	EndIf
	Return $tilesString
EndFunc   ;==>generateCloudsTilestring

Func generateRainTilestring($tile_coords, ByRef $timepathL, ByRef $timepathG)
	If UBound($timepathG) = 2 Then return ""
    ;$tile_coordsG = clampTileCoords($tile_coords, $timepathG)
	$tilesString = ""
	If hasLocalTile($tile_coords) Then
		;$tile_coordsL = clampTileCoords($tile_coords, $timepathL)
        $tilesString &= "1;;0;0;false|wetterradar/prozess/tiles/" & generateTimepathString($timepathL, $tile_coords[2]) & "/512/sprite/" & $tile_coords[0] & "_" & $tile_coords[1] & ".png;"
        $tilesString &= "wetterradarglobal/prozess/tiles/" & generateTimepathString($timepathG, $tile_coords[2]) & "/512/border/" & $tile_coords[0] & "_" & $tile_coords[1] & ".png$s|"
	Else
        $tile_coordsG = factorizeTileCoordinates($tile_coords, $timepathG)
        $tilesString &= $tile_coordsG[3] & "|wetterradarglobal/prozess/tiles/" & generateTimepathString($timepathG, $tile_coordsG[2]) & "/522/sprite/" & $tile_coordsG[0] & "_" & $tile_coordsG[1] & ".png$s|"
    EndIf
	Return $tilesString
EndFunc   ;==>generateRainTilestring

Func generateFlakesTilestring($tile_coords, ByRef $timepathL, ByRef $timepathG)
	If UBound($timepathG) = 2 Then return ""
    ;$tile_coordsG = clampTileCoords($tile_coords, $timepathG)
	$tilesString = ""
	If hasLocalTile($tile_coords) Then
		;$tile_coordsL = clampTileCoords($tile_coords, $timepathL)
        $tilesString &= "1;;0;0;false|wetterradar/prozess/tiles/" & generateTimepathString($timepathL, $tile_coords[2]) & "/512/flakes/" & $tile_coords[0] & "_" & $tile_coords[1] & ".txt;"
        $tilesString &= "wetterradarglobal/prozess/tiles/" & generateTimepathString($timepathG, $tile_coords[2]) & "/512/borderFlakes/" & $tile_coords[0] & "_" & $tile_coords[1] & ".txt$i|"
    Else
        $tilesString &= "1;;0;0|wetterradarglobal/prozess/tiles/" & generateTimepathString($timepathG, $tile_coords[2]) & "/512/flakes/" & $tile_coords[0] & "_" & $tile_coords[1] & ".txt$i|"
    EndIf
	Return $tilesString
EndFunc   ;==>generateFlakesTilestring

Func generateLightningTilestring($tile_coords, ByRef $timepathL, ByRef $timepathG)
	If UBound($timepathG) = 2 Then return ""
    
	;$tile_coordsG = clampTileCoords($tile_coords, $timepathG)
	$tilesString = ""
	If hasLocalTile($tile_coords) Then
		;$tile_coordsL = clampTileCoords($tile_coords, $timepathL)
        $tilesString &= "1;;0;0;false|wetterradarglobal/prozess/tiles/" & generateTimepathString($timepathL, $tile_coords[2]) & "/512/" & $tile_coords[0] & "_" & $tile_coords[1] & ".png;"
        $tilesString &= "wetterradarglobal/prozess/tiles/" & generateTimepathString($timepathG, $tile_coords[2]) & "/512/border/" & $tile_coords[0] & "_" & $tile_coords[1] & ".png"
    Else
        $tilesString &= "1;;0;0|wetterradarglobal/prozess/tiles/" & generateTimepathString($timepathG, $tile_coords[2]) & "/512/" & $tile_coords[0] & "_" & $tile_coords[1] & ".png"
    EndIf
	Return $tilesString
EndFunc   ;==>generateLightningTilestring

Func hasLocalTile($tile_coords)
	Dim $LOWEST_LOCAL_TILE[3] = [28, 16, 6]
	Dim $HIGHEST_LOCAL_TILE[3] = [36, 24, 6]
	Dim $faketimepath[8] = [0, 0, 0, 0, 0, 0, 0, $tile_coords[2]]
	$LOWEST_LOCAL_TILE = factorizeTileCoordinates($LOWEST_LOCAL_TILE, $faketimepath)
	$HIGHEST_LOCAL_TILE = factorizeTileCoordinates($HIGHEST_LOCAL_TILE, $faketimepath)
	;_ArrayDisplay($tile_coords)
	;_ArrayDisplay($WESTERNMOST_LOCAL_TILE)
	Return $LOWEST_LOCAL_TILE[0] < $tile_coords[0] And $LOWEST_LOCAL_TILE[1] < $tile_coords[1] And $HIGHEST_LOCAL_TILE[0] >= $tile_coords[0] And $HIGHEST_LOCAL_TILE[1] >= $tile_coords[1]
EndFunc   ;==>hasLocalTile

Func factorizeTileCoordinates($tile_coords, ByRef $timepath)
    Dim $out_coords[4]
	If $tile_coords[2] > $timepath[7] Then
		$out_coords[0] = 2 * Floor($tile_coords[0] / 2 ^ ($tile_coords[2] - $timepath[7] + 1))
		$out_coords[1] = 2 * Floor($tile_coords[1] / 2 ^ ($tile_coords[2] - $timepath[7] + 1))
		$out_coords[3] = ($tile_coords[2] - $timepath[7] + 1) & ";;"
        $out_coords[3] &= (($tile_coords[0] - $out_coords[0] * 2^($out_coords[3] - 1))/2) & ";"
        $out_coords[3] &= (($tile_coords[1] - $out_coords[1] * 2^($out_coords[3] - 1))/2)
        $out_coords[2] = $timepath[7]
	Else
        $out_coords[0] = $tile_coords[0]
        $out_coords[1] = $tile_coords[1]
        $out_coords[2] = $tile_coords[2]
        $out_coords[3] = "1;;0;0"
    EndIf
	Return $out_coords
EndFunc   ;==>clampTileCoords

Func generateTimepathString($timepath, $zoomlevel = "")
	If $zoomlevel <> "" Then
		$timepath[7] = "ZL" & $zoomlevel
	Else
		$timepath[7] = "ZL" & $timepath[7]
	EndIf
	Return _ArrayToString($timepath, "/")
EndFunc   ;==>generateTimepathString

Func lpad($string, $totallen)
	While StringLen($string) < $totallen
		$string = "0" & $string
	WEnd
	Return $string
EndFunc   ;==>lpad

Func tileCoordsOf($tile_x, $tile_y, $zoomlevel)
	Dim $tile_coords[3] = [$tile_x, $tile_y, $zoomlevel]
	Return $tile_coords
EndFunc   ;==>tileCoordsOf

#cs
 "20220401-0500-2","animationTime": true,"layers": {"europe" : {
 "clouds" : {"hash": "528bb3","ptypPath": "wetterradar/prozess/tiles/","path": "satlayerObs","timePath": ["2022","04","01","05","00","v0"],"mnz": 7},
 "lightning" : {"hash": "73df61","ptypPath": "wetterradarglobal/prozess/tiles/","path": "lightninglayerObs","timePath": ["2022","04","01","05","00","v3"],"mnz": 10},
 "lightningIntensity" : {"hash": "3b937f","ptypPath": "wetterradar/prozess/tiles/","path": "lightningIntensitylayer","timePath": ["2022","04","01","05","00","v6"],"mnz": 6},
 "rain" : {"hash": "29cd52","ptypPath": "wetterradar/prozess/tiles/","path": "rainlayerObs","timePath": ["2022","04","01","05","00","v1"],"mnz": 7},
 "snowflakes" : {"hash": "1f4fd8","ptypPath": "wetterradar/prozess/tiles/","path": "rainlayerObs","timePath": ["2022","04","01","05","00","v1"],"mnz": 10}},

 "global" : {
 "cityWeatherData" : {"hash": "eadb8d","ptypPath": "wetterradarglobal/prozess/tiles/","path": "cityWeatherData","timePath": ["2022","04","01","05","00","v23"],"mnz": 10},
 "clouds" : {"hash": "e32cd0","ptypPath": "wetterradarglobal/prozess/tiles/","path": "satlayerObs","timePath": ["2022","04","01","05","00","v3"],"borderTimePath": ["2022","04","01","05","00","v3"],"mnz": 5},
 "gustlayer" : {"hash": "74ef94","ptypPath": "segelwetterglobal/prozess/tiles/","path": "gustlayerProg","timePath": ["2022","04","01","05","00","v0"],"mnz": 6},
 "lightning" : {"hash": "73df61","ptypPath": "wetterradarglobal/prozess/tiles/","path": "lightninglayerObs","timePath": ["2022","04","01","05","00","v3"],"borderTimePath": ["2022","04","01","05","00","v3"],"mnz": 10},
 "rain" : {"hash": "f253f1","ptypPath": "wetterradarglobal/prozess/tiles/","path": "rainlayerObs","timePath": ["2022","04","01","05","00","v4"],"borderTimePath": ["2022","04","01","05","00","v4"],"mnz": 5},
 "snowflakes" : {"hash": "5f2728","ptypPath": "wetterradarglobal/prozess/tiles/","path": "rainlayerObs","timePath": ["2022","04","01","05","00","v4"],"borderTimePath": ["2022","04","01","05","00","v4"],"mnz": 10},
 "temperaturelayer" : {"hash": "80a253","ptypPath": "segelwetterglobal/prozess/tiles/","path": "temperaturelayerProg","timePath": ["2022","04","01","05","00","v28"],"mnz": 6},
 "windlayer" : {"hash": "8a18db","ptypPath": "segelwetterglobal/prozess/tiles/","path": "windlayerProg","timePath": ["2022","04","01","05","00","v0"],"mnz": 6}},

 "namk" : {"clouds" : {"hash": "589eee","ptypPath": "wetterradarnamk/prozess/tiles/","path": "satlayerProg","timePath": ["2022","04","01","05","00","v21"],"mnz": 7},
 "lightning" : {"hash": "73df61","ptypPath": "wetterradarglobal/prozess/tiles/","path": "lightninglayerObs","timePath": ["2022","04","01","05","00","v3"],"mnz": 10},
 "rain" : {"hash": "41c1c5","ptypPath": "wetterradarnamk/prozess/tiles/","path": "rainlayerObs","timePath": ["2022","04","01","05","00","v0"],"mnz": 7},
 "snowflakes" : {"hash": "4a59a8","ptypPath": "wetterradarnamk/prozess/tiles/","path": "rainlayerObs","timePath": ["2022","04","01","05","00","v0"],"mnz": 10
#ce
