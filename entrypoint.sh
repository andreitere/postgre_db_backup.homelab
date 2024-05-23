#!/bin/bash

# Log the CRON_SCHEDULE
echo "Setting up cron job with schedule: $CRON_SCHEDULE"
echo "Setting up cron job with schedule: $CRON_SCHEDULE" >> /var/log/cron.log

# Create a cron job file
echo "$CRON_SCHEDULE /usr/local/bin/backup.sh >> /var/log/cron.log 2>&1" > /etc/cron.d/backup-cron

# Give execution rights on the cron job file
chmod 0644 /etc/cron.d/backup-cron

# Apply the cron job
crontab /etc/cron.d/backup-cron

# Start cron and tail the log file
cron && tail -f /var/log/cron.log