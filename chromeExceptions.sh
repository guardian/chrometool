#!/bin/sh

##########################################################################
#This script will attempt to add a cookie exception for accounts.google.comn
#to the active user's chrome preferences when the log out.
##########################################################################

#Get the active user name for the log
USER=`id -un`

IFS=$'\n'
CHROME_FOLDER="/Users/home/Library/Application Support/Google/Chrome/"
LOG_FOLDER="/Volumes/Prefs/GNL_MCX_10.8/GNL_updates_log/ChromeExceptions/$(date +"%m-%d-%Y")"
LOG_FILE="$LOG_FOLDER/ChromeExceptionUpdate.log"
PREFS=`find "$CHROME_FOLDER" -d 2 -name Preferences`
TOOLPATH="/Volumes/Prefs/GNL_MCX_10.8/GNL_scripts/tools/ChromeTool"
LONGCOMPUTERNAME=$(scutil --get ComputerName)
SHORTCOMPUTERNAME=$(scutil --get ComputerName | awk -F'_' '{print $1}')

#Make the log folder as required
mkdir -p "$LOG_FOLDER"
chmod 777 "$LOG_FOLDER"

echo "---------------------------------------------------------------------" >> "$LOG_FILE"
echo "$SHORTCOMPUTERNAME:$USER" >> "$LOG_FILE"

for NEXTPREF in $PREFS; do
	"$TOOLPATH" -path "$NEXTPREF" -allow "accounts.google.com" 2>> "$LOG_FILE"
done

echo "---------------------------------------------------------------------" >> "$LOG_FILE"



