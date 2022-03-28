#! /bin/bash
# This script:
#   - disables automatic redirection from port 80 to port 5000
#   - enables automatic redirection from port 80 to port 443 (HTTP to HTTPS)
#
# For the changes to take effect, run:
# bash redirect_to_https.sh
#
# To revert all changes back:
# bash redirect_to_https.sh off
#
# Tested for Sinology DSM 7.0.1

NGINX_CONFIG_FILE="/usr/syno/share/nginx/WWW_Main.mustache"
CUSTOM_PATH=$(dirname "$0")

if [ -s $NGINX_CONFIG_FILE ]; then
    HTML_FILE_NAME=`sed -n "s/^.*rewrite.*\/\(\w*\.html\).*/\1/p" $NGINX_CONFIG_FILE`
    if [[ $1 == off ]]; then
        echo "[OFF] Redirect HTTP to HTTPS"
        sed -i "s/root\s*\(.*\);.*original_path=\(.*\)}}/root \2;/" $NGINX_CONFIG_FILE
        rm "$CUSTOM_PATH/$HTML_FILE_NAME"
    else
        echo "[ON] Redirect HTTP to HTTPS"
        ORIGINAL_PATH=`sed -n "s/root\s*\(.*\);\s*$/\1/p" $NGINX_CONFIG_FILE`

        if [ ! -z "$ORIGINAL_PATH" ] && [ ! -z "$HTML_FILE_NAME" ]; then
            PATCH_SED_CONVERT=$(echo $CUSTOM_PATH | sed 's_/_\\/_g')
            sed -i "s/root\s*\(.*\);\s*$/root $PATCH_SED_CONVERT; {{!original_path=\1}}/" $NGINX_CONFIG_FILE
            if [ ! -s "$CUSTOM_PATH/$HTML_FILE_NAME" ]; then
                echo '<!DOCTYPE html><html><body></body><script type="text/javascript">if (location.protocol !== "https:"){location.protocol = "https:";}</script></html>' >> "$CUSTOM_PATH/$HTML_FILE_NAME"
            fi
        else
            echo "The config file is already patched"
            exit 1
        fi
    fi

    echo "Restarting NGINX ..."
    if which synoservicecfg; then
        synoservicecfg --restart nginx
    else
        synosystemctl restart nginx
    fi
    echo "Script complete"
else
    echo "Missing NGINX config file"
    echo "Script execution stopped"
fi
