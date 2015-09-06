#Database
Our database is developed by Excel VBA which was aimed to hand over to a non-engineering user.

#How to use
- insert data into transaction.xlsm
- insert picture into product code folder 
- update code_description.xlsm
- hit fill blank
- generate report
- generate address

#Functions
- fill blank
  - copy the previous row into each empty row
  - generate box number based on client name
  - generate postal tracking number (last digit will need to be filled up due to the Thailand postal system)
  
![](/git_pic/fill_blank.gif)

- generate report
  - each image has the hyperlink to the real file
  
![](/git_pic/report.png)

- generate address

![](/git_pic/address.png)

#File Structure
- picture
  - product code
    - images.jpg			[insert image]
	- code_description.xlsm [update description]
- address.xlsm
- report.xlsm
- transaction.xlsm 			[update data and generate report]