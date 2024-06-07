#!/bin/bash
#
# Copyright 2021-2024 André Ferreira
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>. 


################################################################################
# Display Help                                                                 #
################################################################################
Help()
{
   echo "This script adds or removes filenames from .gitignore. It's intended"
   echo "to be used as a GIT pre-commit hook when following a whitelist "
   echo "approach and not as a command-line script"
   echo
   echo "Syntax: update-filenames-gitignore [-h|v]"
   echo "Options:"
   echo "h     Print this Help."
   echo "v     Print software version and exit."
   echo
}


################################################################################
# Display Version                                                              #
################################################################################
Version()
{
   echo "Version 1.0.1, 2021-2024 @Copyright André Ferreira"
   echo
}


while getopts ":hv" option;
do
  case $option in
    h)
      Help
      exit 0;;
    v)
      Version
      exit 0;;
    \?)
      echo "ERROR: Invalid argument"
      echo
      exit 1;;
  esac
done

echo "----------------------------------------------------------------------"
echo "Updating .gitignore within pre-commit hook"

insert=false
remove=false
totalInserts=0
totalRemovals=0

for val in $(git diff --cached --name-status)
do
  if [ ${#val} -eq 1 ]; then
    if [ "$val" == "A" ]; then
      insert=true

    elif [ "$val" == "D" ]; then
      remove=true
    fi

  else
    if [ $insert == true ]; then
      if ! grep -q "${val}" .gitignore; then
        echo "!${val}" >> .gitignore
        ((totalInserts++));
      fi

    elif [ $remove == true ]; then
      ex -s +"g/!${val}/d" -cwq .gitignore
      ((totalRemovals++));
    fi

    insert=false
    remove=false
  fi
done


echo "Added ${totalInserts} new filename(s) and removed ${totalRemovals} from .gitignore"


if [ $totalInserts > 0 ] || [ $totalRemovals> 0 ]; then
  $(git add .gitignore)
  echo "Updated .gitignore staged as to commit changes"
fi

echo "----------------------------------------------------------------------"
echo

