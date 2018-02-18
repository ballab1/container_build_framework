# container_build_framework

A framework do simplify 'Dockerfile' and make it easier to build complex containers

## Intoduction

Across the web, there are many examples of container [Dockerfile](https://github.com/search?utf8=%E2%9C%93&q=Dockerfile&type=) configuration files. These range from very simple to complex, almost unreadable files. The general problem, seems to be that everyone attempts to use the **Dockerfile** as a *kitchen sink* and put every command related to the creation of the container, into the Dockerfile itself. The [Dockerfile documentation](https://docs.docker.com/engine/reference/builder/) only describes the directives which may be used. It does not talk about standards or best practices.

This always results in *mixed mode programming*, since the Dockerfile `RUN` command is used. It invokes some other command inside of the build container. Usually, this is a bash script, though it can be any script language. Including these script commands on the `RUN` command, end up with a lot of escaping and formatting because the Dockerfile is not a native file for the script. (Hence: "mixed-mode" program).

This framework takes a differnt approach. It minimizes the 'mixed mode' code, and moves it to a set of small scripts which are `COPY`'d to the build container from where they are run.

#### File Downloads in Dockerfiles
Downloading files is another common pattern which occurs. Somethimes developers verify a PGP signature, or a SHA to validate the downloaded file. I have even seen SHA's downloaded from the same site as a file and used to verify the download. Sometimes, a retry is performed. There is so much duplicated code.

#### Non ROOT user in container
Container security is always a concern, so it pays to be mindful of who owns the process which the container runs. Usually, default is ‘root’ unless you specify `USER` in *Dockerfile*. Also, just because `USER` is specified, that user may not have same uid on host system, as it does inside the container. This can lead to debugging issues, as well as access issues on the host system when `VOLUME`s are also mounted.


## Docker project
A typical project has a `Docker` file. A project using the **container\_lib** framework, contains a `Dockerfile` and a *build* folder. I usually include a *vols* folder for any local mountpoints, as well as a [.dockeringnore](https://docs.docker.com/engine/reference/builder/#dockerignore-file) and the usual meta files for [git](https://git-scm.com/doc). This results in a project folder which looks like:

![container project folder](https://github.com/ballab1/container_build_framework/blob/doc/docs/Container_Project_Folder.png)

The simplified project `Dockerfile` looks like this:

![project Dockerfile](https://github.com/ballab1/container_build_framework/blob/doc/docs/Project_Dockerfile.png)

Depending on the project, there may also be other `ENV`, `EXPOSE`, `ARG` or `ONBUILD` directives, and possibily a `USER` directive.
As can be seen, all of the script code has been moved out of the `Dockerfile`, reducing the *mixed-mode* code, and resulting in simplification. 

## Need for a Framework
The build processes of all containers is always the same. 

1. Install needed OS Support
2. Verify users and groups exist
3. Download & verify external packages
4. Install applications
5. Add customizations and configuration
6. Make sure that ownership & permissions are correct
7. Clean up

Every container will perform one or more of these actions. Many container builds, perform these items multiple times with different targets. Also, in the [Dockerfile](https://github.com/search?utf8=%E2%9C%93&q=Dockerfile&type=) examples, these items are seldom perfomed in any consistent manner. The result can make it not only difficult to debug your own Dockerfiles, but near impossible for someone else to understand, modify and debug your Dockerfiles.


## Framework for Building Containers : [container_build_framework](https://github.com/ballab1/container_build_framework.git)