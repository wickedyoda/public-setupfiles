net use w: \\nas\public
net use s: \\nas\downloadedmedia
net use r: \\nas\downloads
net use t: \\NAS\public-share2

robocopy C:\Users\trave\Downloads \\nas\downloads /z /s /r:2 /w:3 /XD "C:\Users\trave\Downloads\VMs" /xf *.jpg /xf *.iso /xf *.png /xf *.jpeg /xf *.docx /xf *.pdf




