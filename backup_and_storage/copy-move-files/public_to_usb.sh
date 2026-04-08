sudo mount -a

rsync -r -E -z -u --progress --exclude '/vm' --exclude '/proxmox' --delete  /media/naspublic/ /media/traver/4tb/public
