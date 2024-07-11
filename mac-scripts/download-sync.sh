if [ -d "/Users/traver/Downloads/" ]; then
    rsync -r -v /Users/traver/Downloads/ "smb://traver@nas/mac-downloads/apps/"
fi
