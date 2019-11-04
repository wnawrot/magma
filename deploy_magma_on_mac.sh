#!/bin/bash
# Rel.1.1

##############################################################################
#          Fill out your git clone folder and Magma tag                      #
##############################################################################
GIT_CLONE_PATH="/XX/YY/ZZ/";
MAGMA_TAG="v1.0.0-rc1";
##############################################################################

# Functions

countdown() {
    local v=() t=$(stty -g)
    stty -echo
    tput u7
    IFS='[;' read -rd R -a v
    stty $t
    CPos=(${v[@]:1}i)
    CRow=`expr $CPos - 1`
    for ((i=$1;i>=0;i--))
        do
                tput cup $CRow 2
                tput el
                tput civis
                echo -n "`tput setaf 1`$i"
                sleep 1
        done
    tput cup $CRow 0; tput el; tput setaf 7
    }


# Stripping ending "/" in GIT_CLONE_PATH if entered
i=$((${#GIT_CLONE_PATH}-1));if [ "${GIT_CLONE_PATH:$i:1}" == "/" ]; then GIT_CLONE_PATH=${GIT_CLONE_PATH%?};fi

# Variables
AGW_PATH="$GIT_CLONE_PATH/magma/lte/gateway/";
ORC8R_PATH="$GIT_CLONE_PATH/magma/orc8r/cloud/docker/";
NMS_PATH="$GIT_CLONE_PATH/magma/nms/fbcnms-projects/magmalte/";
FEG_PATH="$GIT_CLONE_PATH/magma/feg/gateway/docker/";
CWAG_PATH="$GIT_CLONE_PATH/magma/cwf/gateway/";


####################### Magma deployment section ##########################

# Checking prerequisities
clear; tput setaf 1; echo -e "Starting Magma deployment";
tput setaf 2; echo -e "\n\n[Step 1.] Checking software versions ...\n";
tput setaf 7; echo -e "  Virtualbox: `tput setaf 1; vboxmanage --version`";
tput setaf 7; echo -e "  Python: `tput setaf 1; python3 --version`";
tput setaf 7; echo -e "  Ansible: `tput setaf 1; ansible --version`" | grep -m1 "";
tput setaf 7; echo -e "  Docker: `tput setaf 1; docker --version`";
tput setaf 7; echo -e "  Docker Compose: `tput setaf 1; docker-compose --version`";
tput setaf 7; echo -e "  Terraform: `tput setaf 1; terraform --version`" | grep -m1 "";
tput setaf 7; echo -e "  Vagrant: `tput setaf 1; vagrant --version`";
tput setaf 7; echo -e "  Vagrant VB Guest presence: `tput setaf 1; vagrant plugin list | grep vbguest`";
tput setaf 3; echo -e "\n  Please refer to\n   <https://github.com/facebookincubator/magma/blob/`tput setaf 1`$MAGMA_TAG`tput setaf 3`/docs/Magma_Deployment_Guide_Installing_Magma_V2.pdf>\n   <https://github.com/facebookincubator/magma/blob/`tput setaf 1`$MAGMA_TAG`tput setaf 3`/docs/readmes/basics/prerequisites.md>\n  for prerequisities.\n\n  Make sure that you have several dozens of gigabytes of free disk space, all required apps exist in your system on proper versions and Docker for Mac is running with recommended settings.\n";
tput setaf 3; echo -e "  Press:\n `tput setaf 1`  <c>`tput setaf 3` to continue\n`tput setaf 1`   <i>`tput setaf 3` to interrupt the script";
while true; do read -rsn1 input; if [ "$input" = "i" ]; then echo -e "`tput setaf 3`\n  Exiting ...\n`tput setaf 7`" && exit 0; elif [ "$input" = "c" ]; then break; fi; done;


# Clonning Magma repo
if [ ! -d "$GIT_CLONE_PATH" ]; then
  tput setaf 1; echo -e "\n  Git clone path <$GIT_CLONE_PATH/> you specified does not exist. Create the directory and re-launch the script.\n  Exiting !!!\n `tput setaf 7`" && exit 0
fi

tput setaf 2; echo -e "\n\n[Step 2.] Cloning Magma tag <$MAGMA_TAG> into <$GIT_CLONE_PATH/>\n";

if [ -d "$GIT_CLONE_PATH/magma" ]; then
   tput setaf 3; echo -e "  Magma repo with selected tag `tput setaf 1; cd $GIT_CLONE_PATH/magma; git describe --tags; tput setaf 3`  exists in `tput setaf 1`$GIT_CLONE_PATH/.\n\n`tput setaf 3`  Press:\n `tput setaf 1`  <p>`tput setaf 3` to purge the directory, clone remote repo and set tag `tput setaf 1`$MAGMA_TAG\n   <s>`tput setaf 3` to skip cloning and contnue with existing tag `tput setaf 1; cd $GIT_CLONE_PATH/magma; git describe --tags; tput setaf 1`   <i>`tput setaf 3` to interrupt the script\n\n`tput setaf 1`  [NOTE]`tput setaf 3` Check README.md for tested Magma tags. Using the script with non-tested tags may end up with errors!";
   while true; do
   read -rsn1 input
     if [ "$input" = "i" ]; then
        tput setaf 3; echo -e "\n  Exiting ...\n`tput setaf 7`" && exit 0
     elif [ "$input" = "p" ]; then
	cd $GIT_CLONE_PATH;	
        tput setaf 5; echo -e "\n  2.1. Purging old local repo and cloning new one ...\n";rm -Rf *;
        tput setaf 7; git clone https://github.com/facebookincubator/magma -b $MAGMA_TAG;
        tput setaf 3; echo -e "\n  *** DONE ***\n\nYou are currently on tag `tput setaf 1; cd magma; git describe --tags; tput setaf 7`\n";
	break;
     elif [ "$input" = "s" ]; then 
	tput setaf 3; echo -e "\n  Skipping git clone and continuing with existing repo on tag `cd $GIT_CLONE_PATH/magma; git describe --tags`"; tput setaf 7
        break;
     fi
     done
else
  cd $GIT_CLONE_PATH;
  tput setaf 5; echo -e "\n  2.1. Clonning Magma repo ...\n";
  tput setaf 7; git clone https://github.com/facebookincubator/magma -b $MAGMA_TAG;
  tput setaf 3; echo -e "\n  *** DONE ***\n\n  You are currently on tag `tput setaf 1; cd magma; git describe --tags`\n";
  tput setaf 7;
      	
fi

# Start up Orchestrator and Metrics services
cd $ORC8R_PATH;
tput setaf 2; echo -e "\n\n[Step 3.] Bringing up Orchestrator and Metrics containers:";
tput setaf 3; echo -e "\n  This Magma component is mandatory. If you have already deployed Orc8r you can skip this step";
tput setaf 1; echo -e "\n  [NOTE]`tput setaf 3` Before you start Orc8r deployment make sure that `tput setaf 1`$GIT_CLONE_PATH/magma/modules.yml`tput setaf 3` contains the following modules:\n\n    native_modules:\n    - orc8r\n    - lte\n    - feg\n    - cwag\n";
tput setaf 3; echo -e "  Press:\n `tput setaf 1`  <d>`tput setaf 3` to deploy Orc8r\n`tput setaf 1`   <s>`tput setaf 3` to skip it";
while true; do read -rsn1 input; 
  if [ "$input" = "s" ]; then 
     break; 
  elif [ "$input" = "d" ]; then 
     tput setaf 5; echo -e "\n  3.1. Building images ...\n";
     tput setaf 7; ./build.py;
     tput setaf 3; echo -e "\n  *** DONE ***\n";
     tput setaf 5; echo -e "  3.2. Starting up Metrics services ...\n";
     tput setaf 7; docker-compose -f docker-compose.metrics.yml up -d;
     tput setaf 5; echo -e "\n  3.3. Starting up Orc8r services ...\n";
     tput setaf 7; docker-compose up -d;
     tput setaf 3; echo -e "\n  *** DONE ***\n\n  Waiting 90s for the containers to start up..."; countdown 90; 
     tput setaf 7; echo -e "\n"; docker  ps | grep -E 'orc8r|elastic|CREATED';
     tput setaf 3; echo -e "\n  There should be 12 running containers.\n  Refer to <https://github.com/facebookincubator/magma/blob/`tput setaf 1`$MAGMA_TAG`tput setaf 3`/docs/Magma_Deployment_Guide_Installing_Magma_V2.pdf> to install client's certificate in Firefox (cert password: magma).\n  Once completed check API access by running https://localhost:9443/apidocs\n";
     tput setaf 1; read -p "  Press <Enter> to continue";
     break; 
  fi 
done


# Start up NMS service
cd $NMS_PATH;
tput setaf 2; echo -e "\n\n[Step 4.] Bringing up NMS containers:";
tput setaf 3; echo -e "\n  This Magma component is optional but recommended. If you have already deployed NMS you can skip this step\n"
tput setaf 3; echo -e "  Press:\n `tput setaf 1`  <d>`tput setaf 3` to deploy NMS\n`tput setaf 1`   <s>`tput setaf 3` to skip it";
while true; do read -rsn1 input;
  if [ "$input" = "s" ]; then
     break;
  elif [ "$input" = "d" ]; then
     tput setaf 5; echo -e "\n  4.1. Building images ...\n";
     tput setaf 7; docker-compose build magmalte;
     tput setaf 3; echo -e "\n  *** DONE ***\n";
     tput setaf 5; echo -e "  4.2. Bringing up NMS services ...\n";
     tput setaf 7; docker-compose up -d; wait;
     tput setaf 3; echo -e "\n  *** DONE ***\n\n  Waiting 90s for the containers to start up..."; countdown 90;
     tput setaf 7; docker-compose ps;
     tput setaf 3; echo -e "\n  If any of listed containers is unhealthy press `tput setaf 1`<r>`tput setaf 3` to perform <docker-compose restart>. Otherwise press `tput setaf 1`<c>`tput setaf 3` to continue\n";
     while true; do read -rsn1 input; 
	     if [ "$input" = "r" ]; then 
		tput setaf 7; docker-compose restart;
		tput setaf 3; echo -e "\n  *** DONE ***\n\n  Waiting another 90s for the containers to start up healthy..."; countdown 90; 
		tput setaf 7; docker-compose ps; 
	        tput setaf 3; echo -e "\n  *** DONE ***\n\n  There should be 3 healthy containers.\n";
		tput setaf 3; echo -e "  If any of listed containers is still unhealthy press `tput setaf 1`<r>`tput setaf 3` to perform <docker-compose restart>. Otherwise press `tput setaf 1`<c>`tput setaf 3` to continue\n"; 
	     elif [ "$input" = "c" ]; then 
	        break; 
            fi; 
     done;
     tput setaf 5; echo -e "  4.3. Running dev_setup.sh ...\n";
     tput setaf 7; ./scripts/dev_setup.sh; wait;
     tput setaf 3; echo -e "\n  *** DONE ***\n\n  Checking /etc/hosts of magmalte service for host.docker.internal entry ...\n";
     tput setaf 7; docker-compose exec magmalte /bin/sh -c "cat /etc/hosts" | grep host.docker.internal
     tput setaf 3; echo -e "\n  *** DONE ***\n\n  Check NMS access by running https://localhost in Firefox or Chrome ( u:admin@magma.test p:password1234 )\n";
     tput setaf 1; read -p "  Press <Enter> to continue";
     break;
  fi
done

# Start up FEG
cd $FEG_PATH;
tput setaf 2; echo -e "\n\n[Step 5.] Bringing up FEG:";
tput setaf 3; echo -e "\n  This Magma component is optional. If you have already deployed FEG you can skip this step\n"
tput setaf 3; echo -e "  Press:\n `tput setaf 1`  <d>`tput setaf 3` to deploy FEG\n`tput setaf 1`   <s>`tput setaf 3` to skip it";
while true; do read -rsn1 input;
  
  if [ "$input" = "s" ]; then
     break;
  
  elif [ "$input" = "d" ]; then
     tput setaf 3; echo -e "\n  Press:\n `tput setaf 1`  <c>`tput setaf 3` to deploy containerized version\n`tput setaf 1`   <v>`tput setaf 3` to deploy FEG on Vagrant VM";
     while true; do read -rsn1 input;

       if [ "$input" = "c" ]; then	  
          tput setaf 5; echo -e "\n  5.1. Building images ...\n";
          tput setaf 7; docker-compose build;
          tput setaf 3; echo -e "\n  *** DONE ***\n";
          tput setaf 5; echo -e "  5.2. Bringing up FEG services ...\n";
          tput setaf 7; docker-compose up -d; wait;
          tput setaf 3; echo -e "\n  *** DONE ***\n";
          tput setaf 7; docker-compose ps;
          tput setaf 3; echo -e "\n\n  There should be 15 running containers\n";
          tput setaf 5; echo -e "  5.3. FEG registraion ...\n";
          tput setaf 7; docker-compose exec magmad /usr/local/bin/show_gateway_info.py;
          tput setaf 3; echo -e "\n  Note down Hardware ID and Challenge Key, go to Orch8r or NMS GUI, create FEG network and its config, register FEG using Hardware ID / Challenge Key and add FEG configuration.";
          tput setaf 3; echo -e "  Refer to: <https://github.com/facebookincubator/magma/blob/v1.0.0-alpha1/docs/Magma_Deployment_Guide_Installing_Magma_V2.pdf> (chapter Registering the Network and Gateways) for details.\n";
          tput setaf 1; read -p "  If you are done with the above steps press <Enter> to continue";
          tput setaf 3; echo -e "\n  Waiting 120s for FEG to register"; countdown 120;
          tput setaf 5; echo -e "\n  5.4. Checking FEG registraion ...\n";
          tput setaf 7; docker-compose exec magmad /usr/local/bin/checkin_cli.py;
          tput setaf 3; echo -e "\n  If FEG has been properly registered status should be Success!\n";
          tput setaf 1; read -p "  Press <Enter> to continue";
          break;
       
       elif [ "$input" = "v" ]; then
 
       	  if [ ! -d "$FEG_PATH/../deploy/roles/feg_dev/vars/" ]; then mkdir $FEG_PATH/../deploy/roles/feg_dev/vars/; fi; #Fix playbook error issue 
          cd $FEG_PATH/../
          tput setaf 5; echo -e "\n  5.1. Spinning up and provisioning FEG VM ...\n";
          tput setaf 7; vagrant up feg; wait;
          tput setaf 3; echo -e "\n  *** DONE ***\n";
          tput setaf 7;
          vagrant ssh feg -c '
            cd magma/feg/gateway;
            tput setaf 5; echo -e "  5.2. Performing make ...\n";
            tput setaf 7; export LC_ALL="en_US.UTF-8"; make run; make run_local_hss; 
            tput setaf 3; echo -e "\n  *** DONE ***\n";
            # tput setaf 5; echo -e "  5.3. Restarting FEG servicess ...";
            # sudo service magma@* stop; wait; sudo service magma@magmad restart; sleep 10;
            # tput setaf 3; echo -e "\n  *** DONE ***\n";
            tput setaf 5; echo -e "\n  5.3. Checking status of FEG services ...\n";
	    tput setaf 3; echo -e "  Waiting 60s for FEG services to start up ..."'; 
	  countdown 60;
	  vagrant ssh feg -c '
	    tput setaf 7; echo -e "\n`sudo systemctl status magma@* | grep -B3 Active`";
            tput setaf 3; echo -e "\n  FEG magma services status: `tput setaf 1; sudo systemctl is-active magma@* | wc -l` `tput setaf 3`services active\n"; tput setaf 7;
            tput setaf 5; echo -e "\n  5.4. FEG registration ...\n";
            tput setaf 7; echo -e "`python /usr/local/bin/show_gateway_info.py`";
            tput setaf 3; echo -e "\n  Note down Hardware ID and Challenge Key, go to Orch8r or NMS GUI, create FEG network and its config, register FEG using Hardware ID / Challenge Key and add FEG configuration.";
            tput setaf 3; echo -e "  Refer to: <https://github.com/facebookincubator/magma/blob/v1.0.0-alpha1/docs/Magma_Deployment_Guide_Installing_Magma_V2.pdf> (chapter Registering the Network and Gateways) for details.\n";
            tput setaf 1; read -p "  If you are done with the above steps press <Enter> to continue"; tput setaf 7';
            tput setaf 3; echo -e "\n  Waiting 120s for FEG to register"; countdown 120;
          vagrant ssh feg -c 'tput setaf 7; echo -e "\n  FEG checkin status: `tput setaf 3; sudo cat /var/log/syslog | grep root:Checkin | tail -1`\n"; tput setaf 7';
          tput setaf 1; read -p "  Press <Enter> to continue";
          tput setaf 7;
          break;

       fi
     done
  break
  fi
done

# Start up CWAG
cd $CWAG_PATH;
tput setaf 2; echo -e "\n\n[Step 6.] Bringing up CWAG containers inside CWAG VM:";
tput setaf 3; echo -e "\n  This Magma component is optional. If you have already deployed CWAG you can skip this step\n"
tput setaf 3; echo -e "  Press:\n `tput setaf 1`  <d>`tput setaf 3` to deploy CWAG\n`tput setaf 1`   <s>`tput setaf 3` to skip it";
while true; do read -rsn1 input;
  if [ "$input" = "s" ]; then
     break;
  elif [ "$input" = "d" ]; then
     tput setaf 5; echo -e "\n  6.1. Spinning up and provisioning VM ...\n";
     tput setaf 3; echo -e "  Before you proceed edit $CWAG_PATH/Vagrantfile and";
     tput setaf 3; echo -e "   1) add `tput setaf 1`cwag.vbguest.auto_update = false`tput setaf 3` below `tput setaf 5`cwag.ssh.insert_key = true";
     tput setaf 3; echo -e "   2) save the file.\n";
     tput setaf 1; read -p "  Press <Enter> to continue";
     tput setaf 7; vagrant up cwag; wait;
     tput setaf 3; echo -e "\n  *** DONE ***\n";
     tput setaf 5; echo -e "  6.2. Building images inside CWAG VM ...(it may take really long)\n";
     vagrant ssh cwag -c '
       cd magma/cwf/gateway/docker;
       tput setaf 7; echo -e "`docker-compose build --parallel`";
       tput setaf 3; echo -e "  *** DONE ***\n";
       tput setaf 5; echo -e "  6.3. Bringing up CWAG services inside CWAG VM ...\n";
       tput setaf 7; echo -e "`docker-compose up -d`\n";
       tput setaf 7; echo -e "`docker-compose ps`"';
     tput setaf 3; echo -e "\n  *** DONE ***\n\n  There should be 9 running containers inside CWAG VM\n";
     tput setaf 1; read -p "  Press <Enter> to continue";
     tput setaf 5; echo -e "\n  6.4. CWAG registration ...\n";
     tput setaf 7; vagrant ssh cwag -c '
       cd magma/cwf/gateway/docker; 
       tput setaf 7; echo -e "`sudo docker-compose exec magmad /usr/local/bin/show_gateway_info.py`";
       tput setaf 3; echo -e "\n  Note down Hardware ID and Challenge Key, go to Orch8r or NMS GUI, create CWAG network and its config, register CWAG using Hardware ID / Challenge Key and add CWAG configuration (refer to FEG instructions).";
       tput setaf 1; read -p "  If you are done with the above steps press <Enter> to continue"';
     tput setaf 3; echo -e "\n  Waiting 120s for CWAG to register"; countdown 120;
     tput setaf 5; echo -e "\n  6.5. Checking CWAG registraion ...\n";
     tput setaf 7; vagrant ssh cwag -c '  
       cd magma/cwf/gateway/docker;
       tput setaf 7; echo -e "\n`sudo docker-compose exec magmad /usr/local/bin/checkin_cli.py`";
       tput setaf 3; echo -e "\n  If CWAG has been properly registered status should be Success!\n";
       tput setaf 1; read -p "  Press <Enter> to continue"';
     break;
  fi
done

# Start up AGW
cd $AGW_PATH;
tput setaf 2; echo -e "\n\n[Step 7.] Bringing up AGW:";
tput setaf 3; echo -e "\n  This Magma component is optional. If you have already deployed AWG you can skip this step\n"
tput setaf 3; echo -e "  Press:\n `tput setaf 1`  <d>`tput setaf 3` to deploy AGW\n`tput setaf 1`   <s>`tput setaf 3` to skip it";
while true; do read -rsn1 input;
  if [ "$input" = "s" ]; then
     break;
  elif [ "$input" = "d" ]; then
     tput setaf 5; echo -e "\n  7.1. Spinning up and provisioning AGW VM ...\n";
     tput setaf 7; vagrant up magma; wait;
     tput setaf 3; echo -e "\n  *** DONE ***\n";
     tput setaf 7;
     vagrant ssh magma -c '
       cd magma/lte/gateway;
       tput setaf 5; echo -e "  7.2. Performing make (it can take up to few hours!) ...\n";
       tput setaf 7; make run;
       tput setaf 3; echo -e "\n  *** DONE ***\n";
       tput setaf 5; echo -e "  7.3. Restarting AGW servicess ...";
       sudo service magma@* stop; wait; sudo service magma@magmad restart; sleep 10;
       tput setaf 3; echo -e "\n  *** DONE ***\n";
       tput setaf 7; echo -e "`sudo systemctl status magma@* | grep -B3 Active`";
       tput setaf 3; echo -e "\n  AGW magma services status: `tput setaf 1; sudo systemctl is-active magma@* | wc -l` `tput setaf 3`services active\n"; tput setaf 7';
       tput setaf 5; echo -e "\n  7.4. AGW registration ...\n";
       tput setaf 7; vagrant ssh magma -c '
       tput setaf 7; echo -e "`source /home/vagrant/build/python/bin/activate; show_gateway_info.py`";
       tput setaf 3; echo -e "\n  Note down Hardware ID and Challenge Key, go to Orch8r or NMS GUI, create AGW network and its config, register AGW using Hardware ID / Challenge Key and add AGW configuration (refer to FEG instructions).\n";
       tput setaf 1; read -p "  If you are done with the above steps press <Enter> to continue"; tput setaf 7';
       tput setaf 3; echo -e "\n  Waiting 120s for AGW to register"; countdown 120;

       #tput setaf 5; echo -e "\n  7.4 Creating <test> network and registering AGW in Orc8r as <gw1>";
       #tput setaf 3; echo -e "\n  If you want to change AGW and/or network name edit`tput setaf 1` <$GIT_CLONE_PATH/magma/orc8r/tools/fab/dev_utils.py>\n";
       #tput setaf 1; read -p "  Press <Enter> to continue";
       #tput setaf 7; pwd;fab register_vm;
       #tput setaf 3; echo -e "\n  *** DONE ***\n";
       #tput setaf 3; echo -e "  Waiting 120s for successfull checkin ...."; countdown 120;
  
     vagrant ssh magma -c '
       tput setaf 7; echo -e "\n  AGW checkin status: `tput setaf 3; sudo cat /var/log/syslog | grep root:Checkin | tail -1`\n"; tput setaf 7';
     tput setaf 1; read -p "  Press <Enter> to continue";
     tput setaf 7;
     break;
  fi
done

# Deployment Summary
tput setaf 2; echo -e "\n\n[Step 8.] Magma containers summary:\n";
tput setaf 5; docker ps;
tput setaf 1; echo -e "\n  Enjoy !!!\n";
tput setaf 7;



####################### Magma suspend section ##########################
# TODO


####################### Magma resume section ###########################
# TODO
