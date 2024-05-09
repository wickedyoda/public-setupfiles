net use w: \\nas\public

robocopy "C:\Users\Traver\OneDrive\Family Health Docs" "\\nas\public\Health Documents" /z /s /r:2 /w:1 /purge

robocopy "C:\Users\Trave\OneDrive\Family Health Docs" "C:\Users\trave\Nextcloud\Health Documents" /z /s /r:2 /w:1 /purge

robocopy "C:\Users\trave\Nextcloud\Health Documents" "C:\Users\Trave\OneDrive\Family Health Docs" /z /s /r:2 /w:1 