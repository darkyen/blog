#!/bin/bash
# Create a new post with today's date and prompt for the title.

# Config
editor="subl"
format="md"

# Get layout via getopts (-l)
# --
# http://wiki.bash-hackers.org/howto/getopts_tutorial

while getopts ":l:" opt; do
    case $opt in
        l)
            layout=$OPTARG
            ;;
        :) echo "$opt requires an argument" >&2
            exit 1
            ;;
    esac
done

# Set default config values
# --
# http://www.cyberciti.biz/tips/howto-setting-default-values-for-shell-variables.html

: ${layout:="post"}


# I like giving myself a polite greeting.
# --
# Date codes: http://linux.about.com/od/commands/l/blcmdl1_date.htm

echo "---"
echo "Creating a new ${layout} for" `date +%A", "%B" "%e", "%Y`"."
echo ""
read -p "Enter the title: " title 

# Turn spaces into dashes
# --
# http://stackoverflow.com/questions/1469849/how-to-split-one-string-into-multiple-strings-in-bash-shell

for word in $title
do
    dashedTitle=${dashedTitle}-${word}
done

# Convert title to lowercase
# --
# http://stackoverflow.com/questions/2264428/converting-string-to-lower-case-in-bash-shell-scripting
# http://www.kclug.org/pipermail/kclug/2003-April/015084.html

dashedTitle="`echo ${dashedTitle} | tr '[A-Z]' '[a-z]'`"

# Create a filename with the date, dashed title, and format 
filename="`date +%Y-%m-%d`${dashedTitle}.${format}"
filename="./app/_posts/$filename"

echo $filename

touch $filename

# Add initial YAML to the top of the new bit
echo "---" >> $filename
echo "layout: ${layout}" >> $filename
echo "title: \"${title}\"" >> $filename
echo "summary:" >> $filename
echo "---" >> $filename
echo "" >> $filename

# Open in vim and go to the end of the file ( + )
# --
# http://stackoverflow.com/questions/268123/vim-how-to-start-inserting-at-the-end-of-the-file-in-one-step

${editor} + $filename