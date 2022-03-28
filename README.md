# synology-http-to-https

This script:
- disables automatic redirection from port 80 to port 5000
- enables automatic redirection from port 80 to port 443 (HTTP to HTTPS)

For the changes to take effect, run:
```
bash redirect_to_https.sh
```

To revert all changes back:
```
bash redirect_to_https.sh off
```