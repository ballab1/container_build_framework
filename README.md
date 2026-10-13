# bashlibs

collection of BASH libraries.
Each library has (by convention)
 - the '.bashlib' extension
 - a namespace which is the same as the `basename` of the library with '::' appended. This allows simpler identification and avoids conflicts with otther BASH variables
 - a line near the beginning 'required_libs' which defines any other libraries used
 - should be loaded using the BASH 'source' command, or preferrably the appenv.bashlib in this folder