#!/bin/bash

# TITLE
# Libreoffice ODT to GIT-Friendly

# DESCRIPTION
# Script for converting Libreoffice ODT file format to a git safe format without modifying original document

# SEE ALSO
# https://github.com/TomasHubelbauer/modern-office-git-diff

# Author          Tim Wiel <timwiel@gmail.com>
# Version         20200507



#Variables
ARG_PICTURES=0
ARG_UNZIP=0
PROG_NAME=$0

#Check required commands are installed
if ! [ -x "$(command -v unzip)" ]; then
  echo 'Error: unzip is not installed.' >&2
  exit 1
fi
if ! [ -x "$(command -v pandoc)" ]; then
  echo 'Error: pandoc is not installed.' >&2
  exit 1
fi
if ! [ -x "$(command -v xmllint)" ]; then
  echo 'Error: xmllint is not installed.' >&2
  exit 1
fi

# Transform long options to short ones
for arg in "$@"; do
  shift
  case "$arg" in
    "--input")      set -- "$@" "-i" ;;
    "--pictures")   set -- "$@" "-p" ;;
    "--unzip")      set -- "$@" "-z" ;;
    "--help")       set -- "$@" "-h" ;;
    *)              set -- "$@" "$arg"
  esac
done

#Specify Usage
function help {
  echo "USAGE: $PROG_NAME [-h] -i <file>"
  echo ""
  echo "  where:
    -i  --input         Input file (.odt format)
    -p  --pictures      Extract the pictures
    -z  --unzip         Save the full unzipped ODT (includes -p)
    -h  --help          show this help text
  "
  exit 1
}

#Check for help and invalid options
while getopts ":hi:pz" opt; do
  case $opt in
    h) # Display help
        help
        exit;;
    i) # Check file input is correct
        ARG_FILENAME="$OPTARG"
        if [[ $(file --mime-type -b "$ARG_FILENAME") != application/vnd.oasis.opendocument.text ]]; then
          echo "ERROR: Invalid filetype"
          echo ""
          help
        fi
        ;;
    p) # Save the unzipped ODT contents
        ARG_PICTURES=1
        ;;
    z) # Save the unzipped ODT contents
        ARG_UNZIP=1
        ;;
    \?) # incorrect option
      echo "ERROR: Invalid option"
      echo ""
      help
      exit;;
  esac
done

#Change to the directory of the file
cd $(dirname "$ARG_FILENAME")
FILE_BASENAME=$(basename "$ARG_FILENAME")
GIT_DIR="$FILE_BASENAME.git"

#Recreate the Git Directory
# - We need to remove and allow commands to add again so that removed pictures, objects, etc. in new revisions are removed from GIT
echo "Progress:  Creating Git Directory for ......... $FILE_BASENAME"
rm -fr $GIT_DIR
mkdir -p $GIT_DIR

#Unzip the odt file and change to that directory
if [ $ARG_PICTURES == 1 ]; then
  echo "Progress:  Extractig Pictures ................. $FILE_BASENAME"
  unzip -qo $FILE_BASENAME 'Pictures/*' -d $GIT_DIR
fi

#Unzip the odt file and change to that directory
if [ $ARG_UNZIP == 1 ]; then
  echo "Progress:  Unzipping .......................... $FILE_BASENAME"
  unzip -qo $FILE_BASENAME -d $GIT_DIR
fi

#Change to GIT DIR
cd $GIT_DIR

#Create raw text formats
echo "Progress:  Creating markdown file of .......... $FILE_BASENAME"
pandoc -f odt -i ../$FILE_BASENAME -s -t markdown_strict -o content.md

echo "Progress:  Creating text file of .............. $FILE_BASENAME"
pandoc -f odt -i ../$FILE_BASENAME -s -t plain -o content.txt

if [ $ARG_UNZIP == 1 ]; then
  echo "Progress:  Linting xml from ................... $FILE_BASENAME"
  for f in *.xml; do
    echo $f
    xmllint --format $f --output $f
  done
fi

#Exit the script
exit 0
