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
 cbf.TEMPLATES | action template folders. This is the framework copy of the `action_folders`

These environment variables may be used to source any of the scripts in the action folders using "$( cbf.ACTION )" or from the `action_folders` directories using "$( cbf.ACTION )".
Any script language may be used in the any of the `action_folders', other than *02.users_groups* and *03.downloads*.

### Install needed OS Support
**Folder:** _01.packages_

This folder contains scripts and/or symbolic links which contain commands to install OS functionality. On Alpine Linux, these files contain `apk add` commands.

The following shows an example of the type of file expected in the _01.packages_ folder:
```bash
# core Packages
apk add --no-cache bash-completion coreutils openssh-client shadow supervisor sudo ttf-dejavu unzip
```


### Verify users and groups exist
**Folder:** _02.users_groups_

This folder contains scripts definitions for users and groups to configure inside the container. After stripping off any prefix digits, the name (by convention) should be the same as the associative array declared by the file. All of these array definitions should always be lowercase to prevent name conflicts with **Downloads**.

The `shell` and `home` are optional, while **mandatory fields** are:
- user
- uid
- group
- gid


The *01.hubot* file, shows an example of the type of file expected in the _02.users_groups_ folder:
```bash
# Hubot
declare -A hubot=()
declare bht_uid=${hubot_uid:-2223}
declare bht_gid=${hubot_gid:-2223}
hubot['user']=${HUBOT_USER:-hubot}
hubot['uid']=${bht_uid:-$(getent passwd "${hubot['user']}" | cut -d: -f3)}
hubot['group']=${HUBOT_GROUP:-hubot}
hubot['gid']=${bht_gid:-$(getent group "${hubot['user']}" | cut -d: -f3)}
hubot['shell']=/bin/bash
hubot['home']="${HUBOT_HOME:-/usr/local/hubot}"
# other directories
export HUBOT_HOME="${hubot['home']}"
```
These files may be 'sourced' in later scripts to access their definitions.


### Download & verify external packages
**Folder:** _03.downloads_

This folder contains scripts definitions for files which should be downloaded. After stripping off any prefix digits, the name (by convention) should be the same as the associative array declared by the file.
The **mandatory fields** are
- file
- url
- sha256

Every other declaration is optional.

The *01.PHPADMIN* file, shows an example of the type of file expected in the _03.downloads_ folder:
```bash
# PHPADMIN
declare -A PHPADMIN=()
PHPADMIN['version']=${PHPADMIN_VERSION:-4.7.4}
PHPADMIN['file']="/tmp/phpMyAdmin-${PHPADMIN['version']}-all-languages.tar.gz"
PHPADMIN['url']="https://files.phpmyadmin.net/phpMyAdmin/${PHPADMIN['version']}/phpMyAdmin-${PHPADMIN['version']}-all-languages.tar.gz"
PHPADMIN['sha256']="fd1a92959553f5d87b3a2163a26b62d6314309096e1ee5e89646050457430fd2"
```
The file gets downloaded and saved to the specified file. The sha256 is compared against that calculated from the downloaded file, and if it is the same, the download is considered successful. A max of three retries is performed. The file should be downloaded and the sha256 calculated ahead of building your container. In Linux, the `sha256sum` application can be used. These file may be 'sourced' in later scripts to access their definitions.


### Install applications
**Folder:** _04.applications_

This folder contains scripts which should perform the installation of the major functionality. One script should be used per application installation.

The *02.Gradle* file, shows an example of the type of file expected in the _04.applications_ folder:
```bash
#!/bin/bash
# Gradle installation script
source "${CBF['action']}/03.downloads/01.GRADLE"

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
**Folder:** _05.customizations_

This folder contains scripts  which customize what has been setup so far. A symbolic link to the the script `01.custom_folders` is located in this folder. It copies the content of the custom folders is located. I

The *01.custom_folders* file, shows an example of the type of file expected in the _05.customizations_ folder:
```bash
#!/bin/bash
# 01.custom_folders: copy contents of custme folders from /tmp into the root of the container
declare -r dirs='bin etc home lib lib64 media mnt opt root sbin usr var www'
for dir in ${dirs} ; do
    declare custom_folder="${CBF['base']}/$dir"
    if [ -d "$custom_folder" ]; then
        echo "Updating ${dir} from ${custom_folder}"
        cp -r "${custom_folder}/"* "/${dir}/"
    fi
done
```
The 01.custom_folders canned script is provided with the framework, and linked into a users 'action_folders/05.customizations' folder:


### Make sure that ownership & permissions are correct
**Folder:** _06.permissions_

This folder contains scripts which setup file ownership and permissions.

The *01.docker-entry* file, shows an example of the type of file expected in the _06.permissions_ folder:
```bash
#!/bin/bash
if [ -f /usr/local/bin/docker-entrypoint.sh ]; then
    chmod u+rwx /usr/local/bin/docker-entrypoint.sh
    [ -h /docker-entrypoint.sh ] || ln -s /usr/local/bin/docker-entrypoint.sh /docker-entrypoint.sh
fi
```
There are three canned scripts provided with the framework, and linked into a users 'action_folders/06.permissions' folder:

canned script | functionality provided
--- | ---
 01.bin_dirs | ensures that all files in the /usr/local/bin, /usr/bin and /sbin folders are executable
 01.docker-entry | creates a link in the root folder to /usr/local/bin/docker-entrypoint.sh for backward compatibility and convenience
 01.sudo | checks if /usr/bin/sudo has been installed, ensures that the correct permissions are on the file, and that all files in /etc/sudoers.d  are only accessible by root


### Clean up
**Folder:** _07.cleanup_

This folder contains scripts which cleanup content which is outside of the /tmp folder. A symbolic link to the 99.apk.cleanup script is located here.

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
The 99.apk.cleanup canned script is provided with the framework, and linked into a users 'action_folders/07.cleanup' folder:


**************

## Introduction & Installation
- [Introduction](../README.md)
- [Installation](./Installation.md)

