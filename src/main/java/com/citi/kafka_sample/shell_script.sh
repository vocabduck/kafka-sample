#!/bin/bash

runAsUser=${USER_NAME}

if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "${USER_NAME:-default}:x:$(id -u):0:${USER_NAME:-default} user:/home/${USER_NAME}:/bin/bash" >> /etc/passwd
  fi
fi

# Step 1: Run the init script
echo "Running init-script.ksh..."
/export/app/${COMPONENT_NAME}/init-script.ksh
init_exit_code=$?

if [ $init_exit_code -ne 0 ]; then
  echo "init-script.ksh failed with exit code $init_exit_code"
  exit $init_exit_code
fi

# Step 2: Start SSHD as PID 1
echo "Starting sshd..."
exec /usr/sbin/sshd -D -e -f /etc/ssh/sshd_config
