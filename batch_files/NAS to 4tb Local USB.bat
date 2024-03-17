net use w: \\nas\public
net use s: \\nas\downloadedmedia 
net use r: \\nas\downloads 

robocopy \\nas\public I:\public /z /s /r:2 /w:2 /copy:dt /purge /compress
