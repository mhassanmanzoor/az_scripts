import subprocess
import os

# Function to execute AzCopy command with subprocess
def execute_azcopy_command(command):
    try:
        result = subprocess.run(command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        print(result.stdout)
        return result.returncode
    except subprocess.CalledProcessError as e:
        print(f"Error occurred during AzCopy transfer: {e.stderr}")
        return e.returncode

# Function to build and execute the AzCopy transfer command
def transfer_azure_storage(src_account_url, src_sas_token, dest_account_url, dest_sas_token, log_dir):
    os.makedirs(log_dir, exist_ok=True)

    command = [
        "azcopy", "copy",
        f"{src_account_url}?{src_sas_token}",  # Source URL with SAS token
        f"{dest_account_url}?{dest_sas_token}",  # Destination URL with SAS token
        "--recursive",  # Recursively copy all files
        "--overwrite", "ifSourceNewer",  # Overwrite files if source is newer
        "--check-length=true",  # Ensure files match length on both ends
        "--block-size-mb", "100",  # Transfer in chunks (100 MB)
        "--cap-mbps", "500",  # Limit bandwidth to avoid network saturation
        "--log-level", "INFO",  # Logging level
        f"--log-file={os.path.join(log_dir, 'azcopy.log')}",  # Log file path
        "--resume",  # Resumable transfers in case of interruptions
    ]

    return execute_azcopy_command(command)

# Main function
def main():
    # Define source and destination URLs and SAS tokens
    src_account_url = "https://<source_account>.blob.core.windows.net/<container>/<path>"
    src_sas_token = "<source_sas_token>"
    
    dest_account_url = "https://<destination_account>.blob.core.windows.net/<container>/<path>"
    dest_sas_token = "<destination_sas_token>"

    # Specify log directory for AzCopy logs
    log_dir = "./azcopy_logs"

    # Transfer data
    status = transfer_azure_storage(src_account_url, src_sas_token, dest_account_url, dest_sas_token, log_dir)

    if status == 0:
        print("AzCopy transfer completed successfully.")
    else:
        print("AzCopy transfer encountered errors. Check the log for details.")

if __name__ == "__main__":
    main()
