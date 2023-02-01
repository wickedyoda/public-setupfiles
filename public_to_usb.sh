sudo mount -a

rsync -r --progress --exclude '/vm' --exclude '/proxmox' --delete  /home/pi/naspublic/ /media/pi/4tb
