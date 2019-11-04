

## Purpose:

The **deploy_magma_on_mac.sh** script installs Magma or its individual components on Mac computer including:

    - Orc8r	using docker-compose on Host,
    - NMS	using docker-compose on Host,
    - FEG	using docker-compose on Host or Vagrant VM,
    - CWAG	using docker-compose on Vagrant VM,
    - AGW	using Vagrant VM.

Check details on Magma here: https://github.com/facebookincubator/magma

## Before you start with fresh Magma deployment:

* Installation from scratch with all possible components may take several hours depending on available resources and Internet speed.
* The main prerequisitie is **Docker for Mac** installed and configured with at least **4GB of RAM** (https://github.com/facebookincubator/magma/blob/v1.0.0-rc1/docs/readmes/basics/prerequisites.md).
* To make sure you have enough disk space, and no remainings from old Magma deployments, reset Docker for Mac to factory defaults (*Preferences -> Reset -> Reset to Factory defaults*).
* Delete orphanted Vbox Magma VMs (if any) to regain some disk space and to avoid conflicts.
* Before executing deploy_magma_on_mac.sh:

   * create git clone directory, 
   * edit the script and fill out git clone directory you created,
   * specify Magma tag you want to deploy (for available tags run "git ls-remote --tags https://github.com/facebookincubator/magma")

* If the script fails with any error message, fix issues, re-launch the script and skip completed steps.
* Read script messages carefuly. Make sure you understand what you are doing.
* Check deploy_magma_on_mac.sh release notes for Magma tags the script was tested with.

## Release Notes:

[1.1]
- added FEG deployment options (containerized / Vagrant VM)
- removed AWG autometed registration through "fab"
- added some improvements and fixed some issues
- tested with magma 1.0.0-alpha1 and 1.0.0-rc1
- issues observed: 
    - CWAG started successfully  on Vagrant VM but "pipelined" container is restarting

[1.0]
- Initial version


## TODOs:
- [x] suspend / resume existing Magma deployment

