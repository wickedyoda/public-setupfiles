sudo mount -a -v
rsync -r -t -v -P --delete --exclude '.recycle/*' --exclude 'vm/*' --exclude 'john_deere/*' /home/kali/naspublic /home/kali/4tbdrive