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
* To make sure you have enough disk space, and no remainings from old Magma deployments, reset Docker for Mac to factory defaults (***Preferences -> Reset -> Reset to Factory defaults***).
* Delete orphanted Vbox Magma VMs (if any) to regain some disk space and to avoid conflicts.
* Before executing **deploy_magma_on_mac.sh**:

   * create git clone directory, 
   * edit the script and fill out git clone directory you created,
   * specify Magma tag you want to deploy (for available tags run **git ls-remote --tags https://github.com/facebookincubator/magma**).

* If the script fails with any error message, press CTRL+C, fix issues, re-launch the script and skip completed steps.
* Read script messages carefuly. Make sure you understand what you are doing.
* Check release notes for Magma tags the script was tested with.

## Release Notes:

**[Rel1.1]** (4.11.2019)
- Added FEG deployment options (containerized / Vagrant VM)
- Removed AGW autometed registration through "fab"
- Added some improvements and fixed some issues
- Tested with magma 1.0.0-alpha1 and 1.0.0-rc1
- Perceived issues: 
    - [1.0.0-rc1] CWAG starts up successfully  on Vagrant VM but "pipelined" container is restarting

**[Rel1.0]**
- Initial version


## TODOs:
- [ ] suspend / resume existing Magma deployment

