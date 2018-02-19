# Framework for Building Containers

## Action Folders:

![action folders](https://github.com/ballab1/container_build_framework/blob/dev/refactor/docs/action_folders.png) 

### Install needed OS Support
**Folder:** _01.packages_
This folder contains scripts and/or symbolic links which contain commands to install OS functionality. On Alpine Linux, these files contain `apk add` commands. Example:
```
# core Packages
apk add --no-cache bash-completion coreutils openssh-client shadow supervisor sudo ttf-dejavu unzip 
```


### Verify users and groups exist
**Folder:** _02.users_groups_
This folder contains scripts definitions for users and groups to configure inside the container. After stripping off any prefix digits, the name (by convention) should be the same as the associative array declared by the file.
All of these array definitions should allways be lowercase to prevent name conflicts with ##Downloads## The mandatory fields are
# user
# uid
# group
# gid
`shell` and `home` are optional fields. 
Example of 01.hubot file:
```
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

#directories
export HUBOT_HOME="${hubot['home']}" 
```
These files may be 'sourced' in later scripts to access their definitions.


### Download & verify external packages
**Folder:** _03.downloads_
This folder contains scripts definitions for files which should be downloaded. After stripping off any prefix digits, the name (by convention) should be the same as the associative array declared by the file.
The mandatory fields are
# file
# url
# sha256
Every other declaration is optional. 
Example of 01.PHPADMIN file:

```
# PHPADMIN

declare -A PHPADMIN=()

PHPADMIN['version']=${PHPADMIN_VERSION:-4.7.4}
PHPADMIN['file']="/tmp/phpMyAdmin-${PHPADMIN['version']}-all-languages.tar.gz"
PHPADMIN['url']="https://files.phpmyadmin.net/phpMyAdmin/${PHPADMIN['version']}/phpMyAdmin-${PHPADMIN['version']}-all-languages.tar.gz"
PHPADMIN['sha256']="fd1a92959553f5d87b3a2163a26b62d6314309096e1ee5e89646050457430fd2"

export WWW=/www  
```
The file gets downloaded and saved to the specified file. The sha256 is compared against that calculated from the downloaded file, and if it is the same, the download is considered successful. A max of three retries is performed.
The file should be downloaded and the sha256 calculated ahead of building your container. In Linux, the `sha256sum` application can be used.
These file may be 'sourced' in later scripts to access their definitions.

### Install applications
**Folder:** _04.applications_
This folder contains scripts definitions which should perform the installation of the major functionality. One script should be used per application installation.

### Add customizations and configuration
**Folder:** _05.customizations_
This folder contains scripts definitions which custom what has been setup. This is where the script `01.custom_folders`, to copy the content of the custom folders is located. I
```
#!/bin/bash
# 01.custom_folders: copy contents of custme folders from /tmp into the root of the container

declare -r tools=/tmp
declare -r dirs='bin etc home lib lib64 media mnt opt root sbin usr var'
for dir in ${dirs} ; do
    [ -d "${tools}/${dir}" ] && cp -r "${tools}/${dir}/"* "/${dir}/"
done
true 
```

### Make sure that ownership & permissions are correct
**Folder:** _06.permissions_

### Clean up 
**Folder:** _07.cleanup_
