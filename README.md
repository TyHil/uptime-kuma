# Uptime Kuma Setup and Monitor

Uptime Kuma setup and monitor instructions

## Setup

1. Clone the repo with `git clone https://github.com/TyHil/uptime-kuma.git ~/uptime-kuma` and `cd ~/uptime-kuma`.

2. Run `docker compose up -d`.

3. Follow instructions at http://localhost:3001/dashboard.

## Monitor

1. Configure Docker monitors for each container.

2. Configure local and external HTTPS monitors for websites.

3. Configure push monitors for scheduled scripts (see https://github.com/TyHil/immich).

