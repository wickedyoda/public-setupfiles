net use w: \\nas\public
net use s: \\nas\downloadedmedia 
net use r: \\nas\downloads 
net use t: \\nas\public2



robocopy C:\Users\trave\Downloads\VMs \\nas\public2\vm\abcwhyme /z /s /r:2 /w:2 /copy:dt /compress /purge
