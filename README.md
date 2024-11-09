# bcc-bin

> A script that spawns a random bin (Trashcan) all over the map basond on a config. Characters can then dig through the bin for a random chance at money, weapons, or items. When a player uses a bin it will respawn in another random location. 

## Features
- Random spawn locations set in config
- Random rewards set in config
- Cooldown timer after using the bin
- Enable/Disable blip for bin on map
- Configuration option to use ox_target instead of prompts
- Configuration option to select the notification type from ox or vorp
- Configuration option to enable disable discord logs and grafana logs.

## Installation
1. Make sure dependencies are installed/updated and ensured before this script
2. Extract and place `bcc-bin` into your `resources` folder
3. Add `ensure bcc-bin` to your `server.cfg` file
4. Restart your server

## Dependency
 - [vorp_core](https://github.com/VORPCORE/vorp-core-lua)
 - [vorp_inventory](https://github.com/VORPCORE/vorp_inventory-lua)
 - [bcc-utils](https://github.com/BryceCanyonCounty/bcc-utils)
 - [feather-progressbar](https://github.com/FeatherFramework/feather-progressbar)

## Optional Dependency if You use ox_target or ox notificaiton
 - [ox_target](https://github.com/MrTerabyteLK/ox_target) (Modified ox_target for RedM)
 - [ox_lib](https://github.com/overextended/ox_lib)

## GitHub
- https://github.com/BryceCanyonCounty/bcc-bin
