#!/bin/bash

# on_movie_end /var/lib/motion/motion_video_meta_fix.sh %f
# https://sourceforge.net/p/motion/mailman/message/19931386/
# https://motion-project.github.io/motion_config.html
# https://www.raspberrypi.org/forums/viewtopic.php?t=130309

# chown root:motion motion_video_meta_fix.sh
# chmod 775 motion_video_meta_fix.sh
# chown root:motion motion_video_meta_fix.sh

VIDEO=$1

/usr/bin/exiftool -overwrite_original "-FileModifyDate>CreateDate" $VIDEO
/usr/bin/exiftool -overwrite_original "-CreateDate>FileModifyDate" $VIDEO
#echo $VIDEO >> /var/lib/motion/test1
