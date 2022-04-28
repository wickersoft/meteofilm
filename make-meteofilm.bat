del files.txt
del out.mp4
(for %%i in (meteofilm\*.png) do @echo file '%%i' @) > files.txt
ffmpeg -r 60 -f concat -safe 0 -i files.txt -i afx.mp3 -c:a copy -shortest -c:v libx264 -pix_fmt yuv420p out.mp4
#del files.txt