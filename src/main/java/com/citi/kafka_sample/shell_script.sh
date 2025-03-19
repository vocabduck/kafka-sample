#!/bin/bash

runAsUser=${USER_NAME}

if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "${USER_NAME:-default}:x:$(id -u):0:${USER_NAME:-default} user:/home/${USER_NAME}:/bin/bash" >> /etc/passwd
  fi
fi

# Initialize before starting the service
echo "Running /app/init-script.ksh..."
/app/init-script.ksh
status=$?

if [ $status -ne 0 ]; then
  echo "Init script failed. Exit code: $status"
  exit $status
fi

echo "Starting sshd..."
exec /usr/sbin/sshd -D -e -f /etc/ssh/sshd_config
