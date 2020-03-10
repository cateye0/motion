#!/bin/bash

# on_movie_end /var/lib/motion/motion_video_meta_fix.sh %f
# https://sourceforge.net/p/motion/mailman/message/19931386/
# https://motion-project.github.io/motion_config.html
# https://www.raspberrypi.org/forums/viewtopic.php?t=130309
# https://gist.github.com/rjames86/33b9af12548adf091a26
# exiftool '-datetimeoriginal=2015:01:18 12:00:00' .
# exiftool -time:all -G1 -a -s 2020-02-27-102004-32.mp4

# chown root:motion motion_video_meta_fix.sh
# chmod 775 motion_video_meta_fix.sh
# chown root:motion motion_video_meta_fix.sh


# exiftool "-CreateDate=2018:12:23 00:05:42" 20181223_000542.mp4


VIDEO=$1

setdate=`echo $VIDEO | cut -c 19-35 | sed -r 's/-//g' | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1:\2:\3 \4:\5:\6/'`

echo $setdate
echo $VIDEO

#/usr/bin/exiftool -overwrite_original "-FileModifyDate>CreateDate" $VIDEO
#/usr/bin/exiftool -overwrite_original "-CreateDate>FileModifyDate" $VIDEO
/usr/bin/exiftool -overwrite_original "-CreateDate=$setdate" "-FileModifyDate=$setdate" $VIDEO

