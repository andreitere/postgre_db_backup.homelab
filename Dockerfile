FROM postgres:latest

# Set environment variables for backup
ENV BACKUP_DIR=/backups

# Install cron and curl
RUN apt-get update && apt-get install -y cron curl

# Create backup directory
RUN mkdir -p $BACKUP_DIR

# Add backup script
COPY backup.sh /usr/local/bin/backup.sh
RUN chmod +x /usr/local/bin/backup.sh

# Add entrypoint script to set up cron job
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["cron", "-f"]
