net use w: \\nas\public
net use s: \\nas\downloadedmedia
net use t: \\nas\VM-proxmox
net use r: \\nas\downloads

robocopy "C:\Users\Traver\OneDrive\Personal Vault" "W:\Traver's Personal\Private files\Super Private Files" /z /s /r:2 /w:2 /copy:dt 
robocopy "C:\Users\Trave\OneDrive\Personal Vault" "W:\Traver's Personal\Private files\Super Private Files" /z /s /r:2 /w:2 /copy:dt



