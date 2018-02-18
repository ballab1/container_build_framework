# container_lib

A framework do simplify 'Dockerfile' and make it easier to build complex containers

## Intoduction

Across the web, there are many examples of container **Dockerfile** confifuration files. These range from very simple
to complex, almost unreadable files. The general problem, seems to be that everyone attempts to use the **Dockerfile**
as a *kitchen sink* and put every command related to the creation of the container, into the Dockerfile itself.

This always results in *mixed mode* programming, since the Dockerfile `RUN` command is used. It invokes some other 
command inside of the build container. Usually, this is a bash script, though it can be any script language. Including
these script commands on the `RUN` command, end up with a lot of escaping and formatting because the Dockerfile is
not a native file for the script. (Hence: "mixed-mode" program).

This framework takes a differnt approach. It minimizes the 'mixed mode' code, and moves it to a set of small scripts
which are `COPY`'d to the build container from where they are run.

### File Downloads in Dockerfiles
Downloading files is another common pattern which occurs. Somethimes developers verify a PGP signature, or a SHA to
validate the downloaded file. I have even seen SHA's downloaded from the same site as a file and used to verify the download.
Sometimes, a retry is performed. There is so much duplicated code.

### Non ROOT user in container
Container security is always a concern, so it pays to be mindful of who owns the process which the container runs.
Usually, default is ‘root’ unless you specify `USER` in *Dockerfile*. Also, just because `USER` is specified, that 
user may not have same uid on host system, as it does inside the container. This can lead to debugging issues, as well as
access issues on the host system when `VOLUME`s are also mounted.

