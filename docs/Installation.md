# Framework for Building Containers

## Installation

The framework is installed as a submodule within the `build` folder. In the root folder of your GIT project, type the following:
```
git submodule add https://github.com/ballab1/container_build_framework.git build/container_build_framework
```

The framework gets copied into `tmp` folder in the build environemt along with the other scripts and customizations.
Once installed in a GIT project, configure the project default configuration by running 
```
build/container_build_framework/bin/setupContainerFramework
```

Installing the framework, will setup a `action_folder` folder in the build folder. This contains subfolders for each of the action categories performed.

Folder | Action
--- | --- 
01.packages |  Install needed OS Support
02.users_groups | Verify users and groups exist
03.downloads | Download & verify external packages
04.applications | Install applications
05.customizations | Add customizations and configuration
06.permissions | Make sure that ownership & permissions are correct
07.cleanup | Clean up 

The **/tmp/build** script, called from the *DockerFile*, loads the framework library scripts, and then iterates in order, across the coresponding directories in the `action_folders` folder.
If a folder contains any files, they are processed, otherwise it is skipped. Similarly, if a folder does not exist in the `action_folders' directory, it is skipped.
As the framework processes each action folder, it ignores hidden files, it ignores subfolders and then processes the remaining files and symbolic links in alphabetically sorted order.
For this reason, a convention is adopted, whereby each filename starts with two numbers.

![build folder contents](./build_folder_contents.png) 


### Custom Folders

The `build` folder also contains zero or more **custom folders**. Theese folders are copied to the root of the of the file system of the container. This allows creation of files and subfolders which will be as-is inside your container. No errors occur when any of these folders do not exist.


### Action Folders
The `action_folders` folder contains the instructions for the framework. The contents of this folder are processed in sorted order.



