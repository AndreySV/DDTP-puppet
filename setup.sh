#!/usr/bin/env bash
#
# This script automates ddtp migration to a new server
# and helps to run steps described in README file.
#
# Copyright (C) 2017 Andrey Skvortsov <andrej.skvortzov@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3, or (at your  option)
# any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the  GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301, USA.
#
set -e

function clean_stdin()
{
    local discard
    set +e
    read -t 1 -n 10000 discard
    set -e
}

function install_requirements()
{
    apt-get update
    apt-get install -y puppet sudo

    # install and configure database, webserver and mail server
    puppet apply --modulepath modules/ init.pp

    echo ""
    echo "System configuration is done!"
    echo ""
}

function import_db()
{
    local DB_DUMP_NAME DB_DUMP_PATH
    local REPLY

    DB_DUMP_NAME=pg_ddts_current.dump.gz
    DB_DUMP_PATH=/var/lib/ddtp/$DB_DUMP_NAME
    unset db_is_ready
    if [ ! -f $DB_DUMP_PATH ]; then
        clean_stdin
        read -r -p "Do you want to download database dump from $OLD_DDTP_HOST now (y/n)? " REPLY
        case "$REPLY" in
            y|Y )
                DB_DUMP_PATH=/tmp/$DB_DUMP_NAME
                wget -O $DB_DUMP_PATH http://$OLD_DDTP_HOST/source/$DB_DUMP_NAME;;
        esac
    fi

    if [ -f $DB_DUMP_PATH ]; then
        sudo -u ddtp sh -c "zcat $DB_DUMP_PATH | psql ddtp -q"
        db_is_ready=1

        echo ""
        echo "Database dump imported!"
        echo ""

    else
        echo "Skipped database dump import"
    fi
}

function import_stats()
{
    [ -z "$db_is_ready" ] && return
    local STATS_NAME STATS_PATH
    local REPLY

    STATS_NAME=stats.tar.gz
    STATS_PATH=/var/lib/ddtp/$STATS_NAME
    if [ ! -f $STATS_PATH ]; then
        clean_stdin
        read -p "Do you want to download statistics from $OLD_DDTP_HOST now (y/n)? " REPLY
        case "$REPLY" in
            y|Y )
                STATS_PATH=/tmp/$STATS_NAME
                wget -O $STATS_PATH http://$OLD_DDTP_HOST/source/$STATS_NAME;;
        esac
    fi

    if [ -f $STATS_PATH ]; then
        sudo -u ddtp sh -c "cd ~ddtp/log && tar xzf $STATS_PATH && cd ~ddtp && ./db2web.sh"

        echo ""
        echo "Statistics imported!"
        echo ""
    else
        echo "Skipped statistics import"
    fi
}

function update_translation_packages()
{
    local REPLY

    clean_stdin
    echo ""
    echo "Full update will take a while because it will download all package descriptions "
    echo "for all architectures for all supported distributions and import them into database."
    read -p "Do you want to run full update now, otherwise it'll be run by cron later (y/n)?" REPLY
    case "$REPLY" in
        y|Y )
            sudo -u ddtp sh -c "cd ~ddtp && ./update.sh";;
    esac

    echo ""
    echo "Done"
    echo ""
}



if [ "$EUID" -ne 0 ]; then
    echo "Script has to be run as root"
    exit 1
fi
echo "${OLD_DDTP_HOST:=ddtp2.debian.net} will be used to get DB dump and stats (if necessary)."

install_requirements
import_db
import_stats
update_translation_packages
