robocopy "C:\Users\trave\OneDrive\IT Work" \\nas\public\ITWork /z /s /r:2 /w:2 /copy:dt /purge
robocopy \\nas\public\ITWork "C:\Users\trave\OneDrive\IT Work" /z /s /r:2 /w:2 /copy:dt