#Description Search
- automatically cache code_description.xlsm from database folder into csv files
- input product code to search description from csv cache files
- press up/down to browse through dataset
- press ESC to terminate program

![](/git_pic/description_search.jpg)

#File Structure
- csv [csv cache files]
- source [source code]
- Util
  - csv_update.exe [update the csv cache files if the file size in log.txt is not equal to code_description.xlsm's size]
- description_search.exe [main]
- log.txt [code_description.xlsm's file size from last update]