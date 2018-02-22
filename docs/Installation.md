# Framework for Building Containers

## Installation

The framework is installed as a submodule within the `build` folder. In the root folder of your GIT project, type the following:
```bash
git submodule add https://github.com/ballab1/container_build_framework.git build/container_build_framework
```

The framework gets copied into `tmp` folder in the build environemt along with the other scripts and customizations.
Once installed in a GIT project, configure the project default configuration by running 
```bash
build/container_build_framework/bin/setupContainerFramework
```

Installing the framework, will setup a `action_folder` folder in the build folder. This contains subfolders for each of the action categories performed. It also sets up symlinks in the action folders to scripts maintained in the **action.templates** folder of the container build framework. These scripts perform the most common tasks. The Dockerfile copies these action folders and the framework folder to the **/tmp** folder of the container being built. The last command in the Dockerfile deletes the contents of the **/tmp** folder. The result is that none of the framework, or any of the action folders reside in the final container.

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


The `build` folder also contains zero or more **custom folders**. These folders are copied to the root of the of the file system of the container. This allows creation of files and subfolders which will be as-is inside your container. No errors occur when any of these folders do not exist.

### Action Folders
The **/tmp/build** script, called from the *DockerFile*, loads the framework library scripts, and then iterates in order, across the coresponding directories in the `action_folders` folder.
The `action_folders` folder contains the instructions for the framework. The contents of this folder are processed in sorted order.
If a folder contains any files, they are processed, otherwise it is skipped. Similarly, if a folder does not exist in the `action_folders' directory, it is skipped.
As the framework processes each action folder, it ignores hidden files, it ignores subfolders and then processes the remaining files and symbolic links in alphabetically sorted order.
For this reason, a convention is adopted, whereby each filename starts with two numbers.


### Custom Folders
These folders may contain any content which is copied to the coresponding folder in the root forlder of the container being built.


**************

## Introduction & Documentation
- [Introduction](../README.md)
- [Action Folders](./ActionFolders.md)

