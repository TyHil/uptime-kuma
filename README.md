# Uptime Kuma Setup and Monitor

Uptime Kuma setup and monitor instructions

## Setup

1. Clone the repo with `git clone https://github.com/TyHil/uptime-kuma.git ~/uptime-kuma` and `cd ~/uptime-kuma`.

1. If running alongside Immich run `cp .env.example .env` to enable the extra `docker-compose.immich.yml` file.

1. Run `docker compose up -d`.

1. Follow instructions at http://localhost:3001/dashboard.

## Monitor

1. Set up Discord notifications.

1. Configure Docker monitors for each container.

1. Configure local and external HTTPS monitors for websites.

1. Configure push monitors for scheduled scripts (see https://github.com/TyHil/immich).

1. Configure scheduled storage checking scripts

    a. Run `cp .env.storage.example .env.storage.os` (optionally also `cp .env.storage.example .env.storage.drive` to monitor another drive) and set your mount point and push URL in the new file.
    
    a. Run `crontab -e` and add an entry for `0 5 * * * /home/tyler-hill/uptime-kuma/check-storage.sh /home/tyler-hill/uptime-kuma/.env.storage.os >> /home/tyler-hill/uptime-kuma/check-storage-os.log 2>&1` (optionally also `0 5 * * * /home/tyler-hill/uptime-kuma/check-storage.sh /home/tyler-hill/uptime-kuma/.env.storage.drive >> /home/tyler-hill/uptime-kuma/check-storage-drive.log 2>&1`) with updated paths.
