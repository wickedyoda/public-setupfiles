net use w: \\nas\public
net use s: \\nas\downloadedmedia 
net use r: \\nas\downloads 



robocopy C:\Users\trave\Downloads\VMs \\nas\public2\vm\abcwhyme /z /s /r:2 /w:2 /copy:dt /purge /compress
