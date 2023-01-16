#!/bin/bash

echo "you're in yt.sh script. Welcome !"

ls downloads 2> /dev/null > /dev/null
if [ $? -ne 0 ]; then
    echo "Error: downloads/ does not exist"
    exit 1
fi
youtube-dl -o '~/srv/yt/downloads/%(title)s 2 by %(uploader)s on %(upload_date)s in %(playlist)s.%(ext)s' -f mp4 https://www.youtube.com/watch?v=F9y2KLJSxE8
