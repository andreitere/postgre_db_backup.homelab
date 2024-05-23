#!/bin/bash

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
DATE=$(date +%Y%m%d%H%M%S)

# Backup directory
BACKUP_FILE="$BACKUP_DIR/$APP_NAME/backup_$DATE.tar.gz"

# Temporary files
SCHEMA_FILE="$BACKUP_DIR/$APP_NAME/tmp/schema_$DATE.sql"
DATA_FILE="$BACKUP_DIR/$APP_NAME/tmp/data_$DATE.sql"

# Log file
LOG_FILE="$BACKUP_DIR/$APP_NAME/backup_$DATE.log"

# Start logging
echo "Starting backup at $DATE" >> $LOG_FILE
send_telegram_message "Starting backup at $DATE"

# Export PostgreSQL password
export PGPASSWORD=$POSTGRES_PASSWORD

# Dump the schema
echo "Dumping schema..." >> $LOG_FILE
pg_dump -U $POSTGRES_USER -h $POSTGRES_HOST -d $POSTGRES_DB --schema-only > $SCHEMA_FILE 2>> $LOG_FILE
if [ $? -eq 0 ]; then
    echo "Schema dump completed successfully." >> $LOG_FILE
else
    echo "Schema dump failed." >> $LOG_FILE
    send_telegram_message "Schema dump failed."
    exit 1
fi

# Dump the data
echo "Dumping data..." >> $LOG_FILE
pg_dump -U $POSTGRES_USER -h $POSTGRES_HOST -d $POSTGRES_DB --data-only > $DATA_FILE 2>> $LOG_FILE
if [ $? -eq 0 ]; then
    echo "Data dump completed successfully." >> $LOG_FILE
else
    echo "Data dump failed." >> $LOG_FILE
    send_telegram_message "Data dump failed."
    exit 1
fi

# Archive the dumps
echo "Archiving dumps..." >> $LOG_FILE
tar -czvf $BACKUP_FILE -C $BACKUP_DIR/$APP_NAME/tmp $(basename $SCHEMA_FILE) $(basename $DATA_FILE) >> $LOG_FILE 2>&1
if [ $? -eq 0 ]; then
    echo "Archive created successfully." >> $LOG_FILE
else
    echo "Failed to create archive." >> $LOG_FILE
    send_telegram_message "Failed to create archive."
    exit 1
fi

# Clean up temporary files
echo "Cleaning up temporary files..." >> $LOG_FILE
rm $SCHEMA_FILE $DATA_FILE
if [ $? -eq 0 ]; then
    echo "Temporary files removed successfully." >> $LOG_FILE
else
    echo "Failed to remove temporary files." >> $LOG_FILE
    send_telegram_message "Failed to remove temporary files."
    exit 1
fi

echo "Backup completed at $(date +%Y%m%d%H%M%S)" >> $LOG_FILE

send_telegram_message "Backup completed successfully at $(date +%Y%m%d%H%M%S)"
