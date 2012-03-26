#!/bin/bash
cd /var/www/app/short
thin restart -C thin.yml
