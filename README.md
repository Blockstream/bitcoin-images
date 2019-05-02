## Bitcoin-Related Docker Images
This repository will be continuously maintained, but suggestions, comments, PRs are welcome!
This repository doesn't introduce anything novel, it just accumulates some Bitcoin-related, dockerized daemons/services.

Some simple HOW-TO-RUNs are included. Keep in mind that there have been some assumptions made by the way the HOW-TO-RUNs are defined (i.e. you need to have `/mnt/data/...` created, `bitcoin/lightning.conf` files, etc.). Feel free to make suggestions how to make the services even more generic and simpler to productionize. Also, if you don't want to run as a systemd service, just use the `docker run...` part with its respective options.