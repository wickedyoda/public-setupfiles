sudo mount -a

rsync -r -E -z -u --progress --exclude '/vm' --exclude '/proxmox' --delete  /home/pi/naspublic/ /media/pi/4tb/public
