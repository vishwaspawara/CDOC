#!/bin/bash

BACKUP_PATH="../backup/6.pydeb.tar.gz"
mkdir -p "$(dirname "$BACKUP_PATH")"

tar -czf "$BACKUP_PATH" back_it_up.sh init_pydeb.sh log_pydeb.md pydeb12.qcow2

echo "Backup created at: $BACKUP_PATH"

