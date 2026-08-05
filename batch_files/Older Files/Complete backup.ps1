net use w: \\nas\public
net use s: \\nas\downloadedmedia 
net use z: \\nas\quarantine
net use x: \\nas\samantha-personal 
net use u: \\nas\traver-personal
net use t: \\nas\VM-proxmox 
net use r: \\nas\downloads 
net use v: \\nas\vm-shared 

robocopy C:\Users\trave\Downloads \\NAS\public\downloads /z /s /r:2 /w:3 /copy:dt /XD "C:\Users\trave\Downloads\VMs" /xf *.jpg /xf *.iso

robocopy "C:\Users\trave\OneDrive\IT Work" \\nas\public\ITWork /z /s /r:2 /w:2 /copy:dt /purge
#robocopy C:\Users\trave\OneDrive\education \\NAS\public\education /z /s /r:2 /w:2  /copy:dt /purge
#robocopy "C:\Users\trave\Pictures" "W:\Traver's Personal\Photos" /z /s /r:2 /w:3 /copy:dt
robocopy "C:\Users\trave\Videos" "W:\Traver's Personal\videos" /z /s /r:2 /w:3 /copy:dt


robocopy C:\Users\trave\Downloads\VMs \\nas\public\vm\abcwhyme /z /s /r:2 /w:2 /copy:dt /purge
robocopy e:\vms \\nas\public\vm\murder23 /z /s /r:2 /w:2 /copy:dt /purge