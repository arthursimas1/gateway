# Nginx and Docker -based Gateway
This container gateways all incoming traffic to any registered site.

## Folder and file structure is as following

### Folder
- `/sites-enabled`: each file should be a *nginx config-style* specific to a service;
- `/sites-data`: contains subfolders for each service, each containing its static data;
- `/acme`: contains acme install folder;
- `/ssl-cert`: contains subfolders for each service, each containing `fullchain.pem` and `privkey.pem`;
- `/renew-routines`: renewing scripts for each service based on *acme.sh*;
- `/log`: here resides *nginx* access and error logs;
- `/unix-sockets`: here resides unix sockets to forward connections to.

### Files
- `deploy`: compress all source files, send to server and run `setup`;
- `setup`: installs and starts the container;
- `/entrypoint.sh`: cointainer entrypoint script;
- `/nginx.conf`: main *nginx* config file.
