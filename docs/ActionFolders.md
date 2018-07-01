# Framework for Building Containers

## Action Folders

![action folders](./action_folders.png)

#### Environment
Every script defined in the action folders, is run from the '/tmp' folder as the current directory.
The following environment variables are available:

CBF method | property returned
--- | ---
 cbf.BASE | base folder. In the build container, this is '/tmp'. In the git workspace, this is the 'build' folder.
 cbf.BIN | cbf bin folder. this contains the _setupContainerFramework_ script and test script.
 cbf.ACTION | project actions folder. This contains the folders over which the framework iterates.
 cbf.LIB | cbf library folder. This contains the framework bashlib scripts.
 cbf.TEMPLATE | action template folders. This is the framework copy of the `action_folders`


All scripts used from the `action_folders' get sourced by a bash script.
Any scripts in the action_folders directories which have a special extension { centos alpine fedora unbuntu } will only be used when the base OS of the container corresponds to the extension.
The *03.users_groups* and *04.downloads* are special folders (see below).
Scripts from *07.run.startup* are not executed, but copied to the /usr/local/crf/startup folder. These scripts are executed by the /usr/local/bin/docker-entrypoint.sh script during the container startup.


### Install runtime 'bashlib' libraries
**Folder:** _00.bashlib_

This folder contains bashlib libraries for use by the framework at both buildtime and runtime. These library files should contain only bash function definitions. They should not contain any inline scripts.

The following shows an example of a bashlib file which may be placed the _00.bashlib_ folder:
```
#!/bin/bash
#############################################################################

function www.UID()
{
    local -r user_name="${1:-www-data}"
    local -r default_uid=${2:-82}
    lib.lookupId "$user_name" 'passwd' "$default_uid"
}
export -f www.UID

#############################################################################
function www.GID()
{
    local -r group_name="${1:-www-data}"
    local -r default_gid=${2:-82}
    lib.lookupId "$group_name" 'group' "$default_gid"
}
export -f www.GID
```


### Install add to runtime environment
**Folder:** _01.rt\_environment_

This folder contains scripts which contain commands to update the list of run time environment variables. These files are regular scripts, however, by convention, updating the list of environment variables at this stage of the framework, also makes them available to all of the other scripts during the build. The function **crf.updateRuntimeEnvironment** updates the /usr/local/crf/bin/rt.environment file which contains the list of run time environment variables.

The following shows an example of the type of file expected in the  _01.rt\_environment_ folder:
```
#!/bin/bash
declare -ar env_php=(
    'PHP=php7'
    'SESSIONS_DIR="${SESSIONS_DIR:-/sessions}"'
    'RUN_DIR="${RUN_DIR:-/run/php}"'
)
crf.updateRuntimeEnvironment "${env_php[@]}"
```


### Install needed OS Support
**Folder:** _02.packages_

This folder contains scripts which contain commands to install OS functionality. On Alpine Linux, these files contain `apk add` commands.

The following shows an example of the type of file expected in the _01.packages_ folder:
```bash
# nginx build Packages

declare -a OPTS=( '--virtual' '.buildDependencies' )
declare -a PKGS=( gcc
                  gd-dev
                  geoip-dev
                  gnupg
                  libc-dev
                  libxslt-dev
                  linux-headers
                  make
                  openssl-dev
                  pcre-dev
                  zlib-dev )  
```


### Verify users and groups exist
**Folder:** _03.users_groups_

This folder contains scripts definitions for users and groups to configure inside the container. After stripping off any prefix digits, the name (by convention) should be the same as the associative array declared by the file. All of these array definitions should always be lowercase to prevent name conflicts with **Downloads**.

The `shell` and `home` are optional, while **mandatory fields** are:
- user
- uid
- group
- gid


The *01.hubot* file, shows an example of the type of file expected in the _02.users_groups_ folder:
```
declare -A nginx=(
    ['user']=${NGINX_USER:-nginx}
    ['uid']=${NGINX_UID:-$(nginx.UID)}
    ['group']=${NGINX_GROUP:-nginx}
    ['gid']=${NGINX_GID:-$(nginx.GID)}
    ['shell']=/bin/bash
)
```
These files are 'sourced' by the framework to permit later scripts to access their definitions.


### Download & verify external packages
**Folder:** _04.downloads_

This folder contains scripts definitions for files which should be downloaded. After stripping off any prefix digits, the name (by convention) should be the same as the associative array declared by the file.
The **mandatory fields** are
- file
- url
- sha256

Every other declaration is optional.

The *01.PHPADMIN* file, shows an example of the type of file expected in the _03.downloads_ folder:
```
declare -A NGINX=(
    ['version']=${NGINX_VERSION:-1.15.0}
    ['dir']="/tmp/nginx-${NGINX['version']}"
    ['file']="/tmp/nginx-${NGINX['version']}.tar.gz"
    ['url']="https://nginx.org/download/nginx-${NGINX['version']}.tar.gz"
    ['sha256']="b0b58c9a3fd73aa8b89edf5cfadc6641a352e0e6d3071db1eb3215d72b7fb516"
)
```
The file gets downloaded and saved to the specified file. The sha256 is compared against that calculated from the downloaded file, and if it is the same, the download is considered successful. A max of three retries is performed. The file should be downloaded and the sha256 calculated ahead of building your container. In Linux, the `sha256sum` application can be used.


### Install applications
**Folder:** _05.applications_

This folder contains scripts which should perform the installation of the major functionality. One script should be used per application installation.

The *02.Gradle* file, shows an example of the type of file expected in the _04.applications_ folder:
```bash
#!/bin/bash

mkdir -p /opt
cd /opt
unzip "${GRADLE['file']}"
ln -s "/opt/gradle-${GRADLE['version']}/bin/gradle" /usr/bin/gradle
declare dot_gradle="${GRADLE['home']}/.gradle"
mkdir -p "$dot_gradle"
chown -R gradle:gradle "${GRADLE['home']}"
ln -s "$dot_gradle" /root/.gradle
term.log "Testing Gradle installation${LF}" 'info'
/usr/bin/gradle --version
printf "%s\n" ${GRADLE[@]}
```

### Add customizations and configuration
**Folder:** _06.post_build_mods_

This folder contains scripts  which customize what has been setup so far.

The *01.custom_folders* file, shows an example of the type of file expected in the _05.customizations_ folder:
```bash
#!/bin/bash
# 01.custom_folders: copy contents of custme folders from /tmp into the root of the container
declare -ra dirs=( bin etc home lib lib64 media mnt opt root sbin usr var www )
for dir in "${dirs[@]}" ; do
    declare custom_folder="${cbf.BASE)/$dir"
    if [ -d "$custom_folder" ]; then
        echo "Updating ${dir} from ${custom_folder}"
        cp -r "${custom_folder}/"* "/${dir}/"
    fi
done
```
The 01.custom_folders canned script is provided with the framework.


### Make sure that ownership & permissions are correct
**Folder:** _07.run.startup_

This folder contains scripts which setup file ownership and permissions.

The *01.docker-entry* file, shows an example of the type of file expected in the _06.permissions_ folder:
```bash
#!/bin/bash
if [ -f /usr/local/bin/docker-entrypoint.sh ]; then
    chmod u+rwx /usr/local/bin/docker-entrypoint.sh
    [ -h /docker-entrypoint.sh ] || ln -s /usr/local/bin/docker-entrypoint.sh /docker-entrypoint.sh
fi
```
There are three canned scripts provided with the framework

canned script | functionality provided
--- | ---
 01.bin_dirs | ensures that all files in the /usr/local/bin, /usr/bin and /sbin folders are executable
 01.docker-entry | creates a link in the root folder to /usr/local/bin/docker-entrypoint.sh for backward compatibility and convenience
 01.sudo | checks if /usr/bin/sudo has been installed, ensures that the correct permissions are on the file, and that all files in /etc/sudoers.d  are only accessible by root


### Clean up
**Folder:** _08.cleanup_

This folder contains scripts which cleanup content which is outside of the /tmp folder.

The *99.apk.cleanup* file, shows an example of the type of file expected in the _07.cleanup_ folder:
```bash
#!/bin/bash
if apk info .build-deps; then
    apk del .build-deps
fi
declare -r cacheDir=/var/cache/apk
declare -a files=( $( cbf.getFiles "${cacheDir}" ) )
if [ ${#files[@]} -gt 0 ]; then
    rm -rf "$cacheDir"/*
fi
```
The 99.apk.cleanup canned script is provided with the framework.


**************

## Introduction & Installation
- [Introduction](../README.md)
- [Installation](./Installation.md)
