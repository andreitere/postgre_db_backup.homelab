#!/bin/bash

source /usr/local/bin/env.sh

send_telegram_message() {
    local message=$1
    local bot_token="$TG_BOT_TOKEN"
    local chat_id="$TG_CHAT_ID"
    
    curl -s -X POST https://api.telegram.org/bot$bot_token/sendMessage \
      -d chat_id=$chat_id \
      -d text="$message"
}

# Ensure the backup directory exists
mkdir -p $BACKUP_DIR/$APP_NAME/tmp

# Current date
DATE=$(date +%Y-%m-%d-%H:%M:%S)

# Backup directory
BACKUP_FILE="$BACKUP_DIR/$APP_NAME/backup_$DATE.tar.gz"

# Temporary files
SCHEMA_FILE="$BACKUP_DIR/$APP_NAME/tmp/schema_$DATE.sql"
DATA_FILE="$BACKUP_DIR/$APP_NAME/tmp/data_$DATE.sql"

# Log file
LOG_FILE="$BACKUP_DIR/$APP_NAME/logs/backup_$DATE.log"

# Start logging
echo "Starting backup at $DATE"| tee -a $LOG_FILE
send_telegram_message "Starting backup at $DATE"

# Export PostgreSQL password
export PGPASSWORD=$POSTGRES_PASSWORD

# Dump the schema
echo "Dumping schema... $POSTGRES_USER... $POSTGRES_HOST .. $POSTGRES_DB .. $SCHEMA_FILE" | tee -a $LOG_FILE
pg_dump -U $POSTGRES_USER -h $POSTGRES_HOST -d $POSTGRES_DB --schema-only -f $SCHEMA_FILE 2>> $LOG_FILE
if [ $? -eq 0 ]; then
    echo "Schema dump completed successfully."| tee -a $LOG_FILE
else
    echo "Schema dump failed."| tee -a $LOG_FILE
    send_telegram_message "Schema dump failed."
    exit 1
fi

# Dump the data
echo "Dumping data..."| tee -a $LOG_FILE
pg_dump -U $POSTGRES_USER -h $POSTGRES_HOST -d $POSTGRES_DB --data-only > $DATA_FILE 2>> $LOG_FILE
if [ $? -eq 0 ]; then
    echo "Data dump completed successfully."| tee -a $LOG_FILE
else
    echo "Data dump failed."| tee -a $LOG_FILE
    send_telegram_message "Data dump failed."
    exit 1
fi

# Archive the dumps
echo "Archiving dumps..."| tee -a $LOG_FILE
tar -czvf $BACKUP_FILE -C $BACKUP_DIR/$APP_NAME/tmp $(basename $SCHEMA_FILE) $(basename $DATA_FILE)| tee -a $LOG_FILE 2>&1
if [ $? -eq 0 ]; then
    echo "Archive created successfully."| tee -a $LOG_FILE
else
    echo "Failed to create archive."| tee -a $LOG_FILE
    send_telegram_message "Failed to create archive."
    exit 1
fi

# Clean up temporary files
echo "Cleaning up temporary files..."| tee -a $LOG_FILE
rm $SCHEMA_FILE $DATA_FILE
if [ $? -eq 0 ]; then
    echo "Temporary files removed successfully."| tee -a $LOG_FILE
else
    echo "Failed to remove temporary files."| tee -a $LOG_FILE
    send_telegram_message "Failed to remove temporary files."
    exit 1
fi

COMPLETED_DATE=$(date +%Y-%m-%d-%H:%M:%S)

echo "Backup completed at $COMPLETED_DATE"| tee -a $LOG_FILE

send_telegram_message "Backup completed successfully at $COMPLETED_DATE"
