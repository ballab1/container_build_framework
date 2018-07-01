# Framework for Building Containers

## Installation

The framework may be installed in one of three ways:
1. When a copy of the https://github.com/ballab1/container_build_framework repo is placed in the build folder, it will be used in preference and is a useful way of debugging changes to the framework.
2. Setting the environment variable CBF_VERSION to a valid branch of the https://github.com/ballab1/container_build_framework repo, or to a valid release will download and un-tar to framework to the /tmp folder of the container being built.
3. Every container built using the framework contains a copy of the framework. This will be reused if no other version is supplied.

If you are starting a new container project, create a folder with the name of the project, initialize it as a git repo, then configure the projectby running the setupContainerFramework script
```bash
mkdir newProject
cd newProject
git init
curl https://raw.githubusercontent.com/ballab1/container_build_framework/master/bin/setupContainerFramework -- | sh
```

Once installed in a GIT project, configure the project defaults by running
```bash
build/container_build_framework/bin/setupContainerFramework
```

Configuring the framework will setup the `action_folder` folder in the build folder. This contains subfolders for each of the action categories performed. It also sets up the build.sh in the build folder as well as Dockerfile, docker-compose.yml and the standard git repo files: .gitignore .dockeringnore .gitattributes .lfsconfig


The project `Dockerfile` copies the action folders and the framework folder into the container **/tmp** directory (in the build environment), along with the other scripts and customizations, when building the container. The last command in the Dockerfile deletes the contents of the **/tmp** folder. The result is that none of the framework, or any of the action folders reside in the final container.

![build folder contents](./build_folder_contents.png)


Folder | Action
--- | ---
01.packages |  Install needed OS Support
02.users_groups | Verify users and groups exist
03.downloads | Download & verify external packages
04.applications | Install applications
05.customizations | Add customizations and configuration
06.permissions | Make sure that ownership & permissions are correct
07.cleanup | Clean up


The `build` folder also contains zero or more **custom folders**. These folders are copied to the root of the of the file system of the container.
This allows creation of files and subfolders which will be as-is inside your container. No errors occur when any of these folders do not exist.

### Action Folders
The **/tmp/build.sh** script, called from the *DockerFile*, loads the framework library scripts, and then iterates in order, across the coresponding directories in the `action_folders` folder.

The `action_folders` folder contains the instructions for the framework. The contents of this folder are processed in sorted order.
If a folder contains any files, they are processed, otherwise it is skipped. Similarly, if a folder does not exist in the `action_folders' directory, it is skipped.

As the framework processes each action folder, it ignores hidden files, it ignores subfolders and then processes the remaining files and symbolic links in alphabetically sorted order.
For this reason, a convention is adopted, whereby each filename starts with two numbers.

The framework invokes each action script in its own bash shell to prevent undesired clashes between scripts. All of the framework bash library scripts are available to actions.  The naming convention you see above is important to get the framework to executes scripts in order.  The directories are evaluated in alphabetical order and the scripts in each directory are run in alphabetical order.  Therefore, each directory and script/file starts with a number to ensure that it is executed exactly when it should be.


### Custom Folders
These folders may contain any content which is copied to the coresponding folder in the root forlder of the container being built.
Custom folders are not mandatory. The following custom folders are supported:
bin etc home lib lib64 media mnt opt root sbin usr var www


**************

## Introduction & Documentation
- [Introduction](../README.md)
- [Action Folders](./ActionFolders.md)
