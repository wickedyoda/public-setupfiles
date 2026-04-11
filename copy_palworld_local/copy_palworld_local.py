import ftplib
import os
import time

# FTP Credentials
FTP_HOST = "ftp.example.com"
FTP_USER = "your_username"
FTP_PASS = "your_password"

# Directories
REMOTE_DIR = "/remote_directory"  # Change this to the directory you want to sync
LOCAL_DIR = "/local/directory"  # Change this to the local path where files should be saved

def connect_ftp():
    """Connect to FTP server with passive mode enabled."""
    ftp = ftplib.FTP(FTP_HOST)
    ftp.login(FTP_USER, FTP_PASS)
    ftp.set_pasv(True)  # Enable passive mode
    return ftp

def ensure_local_dir(path):
    """Ensure the local directory exists."""
    if not os.path.exists(path):
        os.makedirs(path)

def download_file(ftp, remote_filepath, local_filepath):
    """Download a file only if it's newer than the local version."""
    try:
        # Get remote file timestamp
        remote_time = ftp.sendcmd(f"MDTM {remote_filepath}")[4:].strip()
        remote_timestamp = time.mktime(time.strptime(remote_time, "%Y%m%d%H%M%S"))

        # Check if the local file exists
        if os.path.exists(local_filepath):
            local_timestamp = os.path.getmtime(local_filepath)
            if local_timestamp >= remote_timestamp:
                print(f"Skipping {remote_filepath} (Already up to date)")
                return  # Skip download if local file is newer

        # Download file
        with open(local_filepath, "wb") as f:
            ftp.retrbinary(f"RETR {remote_filepath}", f.write)

        # Update local file timestamp
        os.utime(local_filepath, (remote_timestamp, remote_timestamp))
        print(f"Downloaded: {remote_filepath} -> {local_filepath}")

    except ftplib.error_perm as e:
        print(f"Failed to download {remote_filepath}: {e}")

def download_directory(ftp, remote_dir, local_dir):
    """Recursively download an entire directory from FTP."""
    ensure_local_dir(local_dir)

    # Change to the target directory
    ftp.cwd(remote_dir)

    # List directory contents
    items = ftp.nlst()

    for item in items:
        remote_path = f"{remote_dir}/{item}"
        local_path = os.path.join(local_dir, item)

        try:
            # Check if item is a directory
            ftp.cwd(remote_path)
            print(f"Entering Directory: {remote_path}")
            download_directory(ftp, remote_path, local_path)
            ftp.cwd("..")  # Go back after downloading the directory
        except ftplib.error_perm:
            # If changing directory fails, it's a file
            download_file(ftp, remote_path, local_path)

def main():
    """Main function to sync FTP directory."""
    ftp = connect_ftp()
    print(f"Connected to {FTP_HOST}")

    download_directory(ftp, REMOTE_DIR, LOCAL_DIR)

    ftp.quit()
    print("FTP Sync Completed.")

if __name__ == "__main__":
    main()