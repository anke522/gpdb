#!/bin/bash

# This file has the .sql extension, but it is actually launched as a shell
# script. This contortion is necessary because pg_regress normally uses
# psql to run the input scripts, and requires them to have the .sql
# extension, but we use a custom launcher script that runs the scripts using
# a shell instead.

TESTNAME=norewind
STOP_MASTER_BEFORE_PROMOTE=true

. sql/config_test.sh

# Nothing to do here
function before_master
{
:
}

# Nothing to do here
function before_standby
{
:
}

# Nothing to do here
function standby_following_master
{
:
}

# Run checkpoint to update Control File with new timeline ID
function after_promotion
{
PGOPTIONS=${PGOPTIONS_UTILITY} $STANDBY_PSQL -c "SELECT state FROM pg_stat_replication;"
}

# Should show one row in streaming state and log should have "no rewind
# required". The old master will automatically do timeline switch after getting
# promoted mirror's new timeline history file.
function after_rewind
{
PGOPTIONS=${PGOPTIONS_UTILITY} $STANDBY_PSQL -c "SELECT state FROM pg_stat_replication;"
grep "no rewind required" $log_path
}

# Run the test
. sql/run_test.sh
