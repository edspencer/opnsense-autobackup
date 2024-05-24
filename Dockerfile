# Use a lightweight base image
FROM alpine:latest

# Install curl, git, and cron
RUN apk --no-cache add curl git busybox-suid

# Copy the entrypoint script into the container
COPY entrypoint.sh /entrypoint.sh

# Make the entrypoint script executable
RUN chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]