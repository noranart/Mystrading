#Instagram Follow
A bot for Instagram upload. The software will upload only 5 images every half an hour for each id. We tested several amount of images and found that 5 images/half an hour is the ceiling number which our clients could tolerate and stay following to our account.

![](/git_pic/instagram_upload.gif)

#How to use
- install [Arc Welder](https://developer.chrome.com/apps/getstarted_arc)
- install [Instwogram](http://forum.xda-developers.com/showthread.php?t=2683570) on Arc Welder
- update List Folder
  - each folder name is the login username
  - images in each folder is the uploaded images
  - image's file name must be the same code as code_description.xlsm
  - [optional] update signature.txt for description footer
- update Instwogram.lnk (Arc Welder generates apk shortcut based on computer's signature)
- run instagram_upload.exe
- press ctrl+capslock to update login password
- press ctrl+q to terminate program
* the software was designed for Arc Welder v.44.4410.376.15, App Runtime for Chrome (Beta) v.44.4410.376.16, Instwogram 6.18.0

#Flowchart
The system mainly consists of 5 actions
- login/logout
- description search
- upload
- diagnostic
- delay

![](/git_pic/instagram_upload_flowchart.png)

#File Structure
- List [username, images]
- Source [source code and icon]
- Util
  - send.exe [fix explorer stucks on file browser]
- instagram_upload.exe [main]
- Instwogram.lnk [relaunch on error]
- option.ini [encrypt password]