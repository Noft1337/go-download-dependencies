# Download Golang Dependencies
This repo contains a bash script that downloads a **Golang** package and then all of its dependencies.  
To use this script you have to have these commands available:
- `go`
- `jq`
- `python`

## Run
To run this script, run this:
```
# Supply your own outupt directory
./run <go_module>@<version> </path/to/dir>

# Generate an output directory in current workdir
./run <go_module>@<version>
```
