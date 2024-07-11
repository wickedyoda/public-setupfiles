net use w: \\nas\public
net use s: \\nas\downloadedmedia 
net use r: \\nas\downloads 

robocopy F:\Downloads\VMs \\NAS\public-share2\vm\traver-desk /z /s /r:2 /w:2 /copy:dt /purge /compress
