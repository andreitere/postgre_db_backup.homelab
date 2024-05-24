#!/bin/bash

cat <<EOL > /usr/local/bin/env.sh
TG_BOT_TOKEN="$TG_BOT_TOKEN"
TG_CHAT_ID="$TG_CHAT_ID"
POSTGRES_USER="$POSTGRES_USER"
POSTGRES_PASSWORD="$POSTGRES_PASSWORD"
POSTGRES_DB="$POSTGRES_DB"
POSTGRES_HOST="$POSTGRES_HOST"
BACKUP_DIR="$BACKUP_DIR"
APP_NAME="$APP_NAME"
CRON_SCHEDULE="$CRON_SCHEDULE"
EOL

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
