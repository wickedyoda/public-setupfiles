sudo mount -a -v
rsync -r -t -v -P --delete --exclude '.recycle/*' --exclude 'vm/*' --exclude 'john_deere/*' /media/naspublic /home/pi/4tbdrive
