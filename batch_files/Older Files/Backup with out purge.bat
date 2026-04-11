net use w: \\nas\public
net use x: \\nas\devry
net use y: \\nas\docker
net use z: \\nas\downloads
net use u: \\nas\AudioBooks
net use t: \\nas\Personal
net use s: \\nas\downloadedmedia
net use r: \\nas\vm

robocopy C:\Users\trave\OneDrive\Ark "d:\nas1public\Ark" /z /s /r:2 /w:3  /copy:dts /purge
robocopy C:\Users\trave\OneDrive\Documents d:\nas1public\documents /z /s /r:2 /w:2 /copy:dts 
robocopy "C:\Users\trave\OneDrive\Family Health Docs" d:\nas1public\FamilyHealthDocs /z /s /r:2  /w:3 /copy:dts
robocopy C:\Users\trave\OneDrive\Devry D:\nas1devry /z /s /r:2 /w:2 /copy:dts /purge
robocopy C:\Users\trave\OneDrive\Desktop d:\nas1public\desktop /z /s /r:2 /w:2 /copy:dts /purge
robocopy C:\Users\trave\Downloads d:\nas1public\Downloads /z /s /r:2 /w:3 /copy:dts /XD "C:\Users\trave\Downloads\VMs" 
robocopy "C:\Users\trave\OneDrive\IT Work" d:\nas1public\ITWork /z /s /r:2 /w:2 /copy:dts /purge
robocopy C:\Users\trave\Downloads\VMs d:\vms /z /s /r:2 /w:3 /copy:dts

robocopy C:\Users\trave\Downloads\VMs \\nas\vm /z /s /r:2 /w:2 /copy:dts
robocopy C:\Users\trave\OneDrive\Ark \\NAS\public\Ark /z /s /r:2 /w:3  /copy:dts /purge
robocopy C:\Users\trave\OneDrive\Documents \\NAS\public\documents /z /s /r:2 /copy:dts /w:2  
robocopy "C:\Users\trave\OneDrive\Family Health Docs" \\NAS\public\FamilyHealthDocs /z /copy:dts /s /r:2  /w:3 /purge
robocopy C:\Users\trave\OneDrive\Devry \\NAS\devry /z /s /r:2 /w:2  /copy:dts /purge
robocopy C:\Users\trave\OneDrive\Desktop \\NAS\public\desktop /z /s /r:2 /w:2  /copy:dts /purge
robocopy "C:\Users\trave\OneDrive\IT Work" \\nas\public\ITWork /z /s /r:2 /copy:dts /w:2  /purge
robocopy C:\Users\trave\OneDrive\Documents\Docker \\NAS\docker /z /s /r:2 /w:3 /copy:dts /purge

robocopy C:\Users\trave\Videos\ \\nas\personal\videos /z /s /r:2 /copy:dts /w:2 /purge

robocopy C:\Users\trave\Downloads \\NAS\public\downloads /z /s /r:2 /w:3 /copy:dts /XD "C:\Users\trave\Downloads\VMs"
robocopy \\NAS\public d:\nas1public /z /s /r:2 /w:3 /copy:dts /purge
robocopy \\nas\vm d:\vms /z /s /r:2 /w:3 /copy:dts /purge
