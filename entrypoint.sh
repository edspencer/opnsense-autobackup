#!/bin/sh

# Ensure necessary environment variables are set
if [ -z "$HOSTNAME" ]; then
  echo "HOSTNAME environment variable is not set"
  exit 1
fi

# Construct the full URL
FIREWALL_URL="https://${HOSTNAME}/api/core/backup/download/this"

# Set up git configuration
git config --global user.name "$GIT_USERNAME"
git config --global user.email "$GIT_EMAIL"

# Function to perform the backup
backup() {
  echo "Starting backup process..."
  # Create a directory to clone the repository if it doesn't exist
  mkdir -p /repo

  # Clone the repository
  echo "Cloning the repository..."
  git clone https://$GIT_TOKEN@${GIT_REPO_URL#https://} /repo

  # Check if the clone was successful
  if [ ! -d "/repo" ]; then
    echo "Failed to clone the repository"
    exit 1
  fi

  # Change to the repository directory
  cd /repo || exit 1

  # Get today's date
  TODAY=$(date +%Y-%m-%d)

  # Run the curl command and save the backup
  echo "Downloading backup..."
  curl -k -u "$API_KEY:$API_SECRET" "$FIREWALL_URL" > latest.xml

  # Save another copy of the file with today's date
  echo "Saving backup as latest.xml and opnsense_$TODAY.xml..."
  cp latest.xml opnsense_$TODAY.xml

  # Add the backup files to the repository
  git add latest.xml opnsense_$TODAY.xml

  # Commit the backup files with today's date in the commit message
  git commit -m "Backups generated $TODAY"

  # Push the changes to the repository
  git push origin main

  echo "Backup process completed."
}

if [ -z "$CRON_SCHEDULE" ]; then
  # Run the backup immediately if CRON_SCHEDULE is not provided
  echo "No CRON_SCHEDULE provided. Running backup immediately..."
  backup
else
  # Write out the cron schedule to a file
  echo "CRON_SCHEDULE provided: $CRON_SCHEDULE. Setting up cron job..."
  echo "$CRON_SCHEDULE /entrypoint.sh backup" > /etc/crontabs/root

  if [ "$1" = "backup" ]; then
    backup
  else
    # Start cron in the background
    echo "Starting cron service..."
    crond -f &
    CRON_PID=$!

    # Run the initial backup
    backup

    # Wait for cron to keep the container running
    wait $CRON_PID
  fi
fi