 #!/bin/bash          

echo '---------------'
echo '---------------'
echo $(date)

file_processing=processing
file_to_process=to_process.csv
file_processed=processed.csv
start_path='../../public'
processed_folder='/processed/'

####################################
# see if another instance of this script is running
# if so, stop this one
if [ ! -e "$file_processing" ]; then
  touch "$file_processing"
else
  # script is already running, so stop
  echo "**** script is already running, stopping"
  exit 0
fi  

####################################
# get number of lines in file
num_lines=$(wc -l < $file_to_process)
echo ****number of videos left: $num_lines

####################################
# while there are rows , continue
while [ "$num_lines" -gt 0 ]; do
  echo '---------------'

  ####################################
  # read in the first row
  read -r row < $file_to_process
  echo row data: $row

  ####################################
  # if row has content, continue
  if [ -n "$row" ]; then
    ####################################
    # pull out the file name
    file="${row##*,}"
    echo original file path: $file


    ####################################
    # set new file variables
    parent=$(dirname "$file")
    new_dir_path=$(dirname "$parent")
    #echo $new_dir_path
    #extension="${file##*.}"
    #echo $extension
    filename=$(basename "$file")
    filename="${filename%.*}"
    echo raw filename: $filename
    original_file="$start_path$file"
    echo path to original file: $original_file
    new_folder="$start_path$new_dir_path$processed_folder"
    #echo $new_folder
    new_file="$new_folder$filename.mp4"
    echo path to new file: $new_file


    ####################################
    # if image exists, continue
    if [ -e "$original_file" ]; then

      ####################################
      # if processed folder does not exist, create it
      if [ ! -d "$new_folder" ]; then
        mkdir "$new_folder"
      fi  


      ####################################
      # process the image
#      avconv -y -i $original_file -c:v libx264 -r 25 -crf 22 -movflags +faststart $new_file
#      avconv -y -i $original_file -c:v libx264 -r 25 -crf 22 $new_file
#      avconv -y -i $original_file -c:v libx264 -r 25 $new_file
      ffmpeg -y -i $original_file -c:v libx264 -r 25 -movflags +faststart $new_file


      ####################################
      # add this row to the processed file
      # - make sure file exists
      if [ ! -e "$file_processed" ]; then
        touch "$file_processed"
      fi  
      echo "$row" >> "$file_processed"

    fi  


  fi

  ####################################
  # delete the first row since the image is processed
  sed -i '1d' $file_to_process


  ####################################
  # get number of lines in file
  num_lines=$(wc -l < $file_to_process)
  echo ****number of videos left: $num_lines
done



####################################
# delete processing file
rm "$file_processing"
