#!/bin/bash
# Combines rendered video with soundtrack, then builds the compilation.
set -e
cd "$(dirname "$0")/../build"
for e in 1 2 3; do
  ffmpeg -y -loglevel error -i ep$e-video.mp4 -i ep$e.wav -c:v copy -c:a aac -b:a 192k -ac 2 -shortest -movflags +faststart Bajki-z-Lasu-Kropki-odcinek-$e.mp4
done
printf "file 'Bajki-z-Lasu-Kropki-odcinek-%s.mp4'\n" 1 2 3 > list.txt
ffmpeg -y -loglevel error -f concat -safe 0 -i list.txt -c copy -movflags +faststart Bajki-z-Lasu-Kropki-skladanka.mp4
rm list.txt
