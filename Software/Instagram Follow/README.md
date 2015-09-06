#Instagram Follow
A bot for Instagram auto follow/unfollow based on input users.

![](/git_pic/instagram_follow.gif)

#How to use
- install [Arc Welder](https://developer.chrome.com/apps/getstarted_arc)
- install [Instwogram](http://forum.xda-developers.com/showthread.php?t=2683570) on Arc Welder
- update List Folder
  - each file name is the login username
  - content in each file is the target's username
- update Instwogram.lnk (Arc Welder generates apk shortcut based on computer's signature)
- run instagram_follow.exe
- press ctrl+capslock to update login password
- press ctrl+q to terminate program
* the software was designed for Arc Welder v.44.4410.376.15, App Runtime for Chrome (Beta) v.44.4410.376.16, Instwogram 6.18.0

#Flowchart
The system mainly consists of 4 actions
- login/logout
- follow
- unfollow
- diagnostic

![](/git_pic/instagram_follow_flowchart.png)

#File Structure
- List [username, target]
- Source [source code and icon]
- instagram_follow.exe [main]
- Instwogram.lnk [relaunch on error]
- option.ini [encrypt password]