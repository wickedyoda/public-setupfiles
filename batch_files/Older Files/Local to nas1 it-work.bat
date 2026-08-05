net use z: /delete
net use y: /delete
net use x: /delete
net use w: /delete
net use v: /delete
net use u: /delete
net use v: /delete
net use t: /delete


net use y: \\nas1\public
net use x: \\nas1\devry
net use z: \\nas1\docker
net use w: \\rasp2\share

robocopy "C:\Users\trave\OneDrive\IT Work" \\nas1\public\it-work /z /s /r:2 /w:3 /copy:dt
