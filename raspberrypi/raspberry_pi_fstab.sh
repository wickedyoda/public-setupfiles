# ----------------------------------------------------------------------
# | creates folders for shares, Install fstab entries, maps mounts to nas|
# ----------------------------------------------------------------------

sudo cp /etc/fstab /etc/ftab.orig.backup

# cd ~/home/pi

sudo mkdir /home/pi/naspublic
sudo mkdir /home/pi/nasdownloadedmedia

sudo echo "//nas/public  /home/pi/naspublic  cifs  vers=2.0,username=admin,password=mypassword,file_mode=0777,dir_mode=0777 0 0
//nas/DownloadedMedia  /home/pi/nasdownloadedmedia  cifs vers=2.0,username=traver,password=mypassword,file_mode=0777,dir_mode=0777 0 0" >> /etc/fstab

sudo mount -a