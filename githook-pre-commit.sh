#!/bin/bash

# TITLE
# Git Pre-Commit Hook to run libreoffice2git.sh

# DESCRIPTION
# A Git Pre-Commit Hook to run the libreoffice2git.sh if the base .odt file has changed

# Author          Tim Wiel <timwiel@gmail.com>
# Version         20200508

#Git root directory
GIT_ROOT=$(pwd)

#Run over the files to be committed
while read status file; do
  # skip deleted files
  if [ "$status" == 'D' ]; then continue; fi
  # Do a check only on the office files
  #if [[ "$file" =~ (.odt|.odc)$ ]]; then
  if [[ "$file" =~ .odt$ ]]; then
    if [ -d "$GIT_ROOT/$file.git" ]; then
      #Run the libreoffice2git.sh script
      $GIT_ROOT/libreoffice2git.sh --pictures --input $GIT_ROOT/$file > /dev/null 2> /dev/null
      git add $GIT_ROOT/$file.git > /dev/null 2> /dev/null
    fi
  fi
done < <(git diff --cached --name-status)
exit 0;