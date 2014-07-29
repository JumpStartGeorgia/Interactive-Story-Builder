 #!/bin/bash          

echo '---------------'
echo '---------------'

file_processing=processing
file_to_process=to_process.csv
file_processed=processed.csv

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
    file="${row}"
    echo file: $file

    ####################################
    # set new file variables
    parent=$(dirname "$file")
    new_dir_path=$(dirname "$parent")
    echo new_dir_path: $new_dir_path
    filename=$(basename "$file")
    echo filename: $filename
    new_file=$new_dir_path/$filename
    echo new_file: $new_file
    
    ####################################
    # if image exists, continue
    if [ -e "$file" ]; then
      ####################################
      # process the image
#      avconv -y -i $file -c:v libx264 -movflags +faststart -r 25 -crf 22 $new_file
#      avconv -y -i $file -c:v libx264 -r 25 -crf 22 $new_file
      avconv -y -i $file -c:v libx264 -r 25 $new_file


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
