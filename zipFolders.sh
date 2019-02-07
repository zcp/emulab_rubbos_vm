#!/bin/bash
#./zipFolders.sh dir
dir=$1
cd $dir
#convert a string to an array
folders=($(ls -d */))

echo $folders
echo ${#folders[@]} 
if [ ${#folders[@]} -gt 0 ]; then  # $n is still undefined!
   for folder in "${folders[@]}"; do
       echo $folder
       #remove "/"
       modified_folder="${folder%/}"
       echo $modified_folder
       zip -r $modified_folder.zip $modified_folder
   done
fi


