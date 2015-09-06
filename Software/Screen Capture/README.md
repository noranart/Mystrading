#Screen Capture
A square image capturing software which automatically links the url and files to database system.

![](/git_pic/screen_capture.gif)

#How to use
- run screen_capture.exe
- insert "database\picture" directory
- run code_description.xlsm
- press capslock to create layer
- press ESC to close layer
- press shift+capslock to save image and url
- press ctrl+capslock for option
- press ctrl+q to terminate program

#Option
- size 
  - image size in pixel
- code 
  - insert code to left box to auto generate the latest image number
  - insert number to right box to manually change image number
  - if the code_description.xlsm is opened, layer will be red, and the link will be stored in excel.
  - code will be embedded to the bottom right of each image
- db
  - reference path for auto generate image number
- save
  - image output location
- center/edge
  - position of layer related to mouse pointer
- autosave
  - autosave every capslock press

#File Structure
- Source [source code and icon]
- Util [option]
- option.ini [option parameters]
- screen capture.exe [main]