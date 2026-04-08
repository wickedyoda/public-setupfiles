sudo mount -a

rsync -r --progress --exclude '/vm' --exclude '/proxmox' --exclude '/.recycle' --delete  /home/pi/naspublic/ /media/pi/4tb/public
