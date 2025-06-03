# StackRox ClusterLocal Cleanup

Images may be flagged as cluster local if previously scanned via 'delegation' but no longer is. This utility assists in identify images flagged as cluster local and can re-scan them - which will clear the flag.

## Usage

```sh
export ROX_ENDPOINT=...
export ROX_API_TOKEN=...

# Will detect images flagged as cluster local and write the output to `tmp-cluster-local-images.json`
./detect.sh

# Will run `roxctl image scan` for each image in `tmp-cluster-local-images.json`, on success the clusterLocal flag is cleared 
./scan.sh
```

## Example

```
$ ./detect.sh
Pulling Central metadata
{"version":"4.7.3","buildFlavor":"release","releaseBuild":true,"licenseStatus":"VALID"}

Searching for cluster local images
{"id":"sha256:ccbbc30b4057f9364bf31e27e25c773f5f83cb3ed908bb2994cd2993fcbbad85","name":"docker.io/library/nginx:latest"}

Found 1/93 images flagged as clusterLocal
```

```
$ ./scan.sh
Pulling Central metadata
{"version":"4.7.3","buildFlavor":"release","releaseBuild":true,"licenseStatus":"VALID"}

Current delegated scanning config:
{"enabledFor":"NONE","defaultClusterId":"","registries":[]}

Are you sure you want to re-scan 1 images? [Y/n]: 

Scanning image: docker.io/library/nginx:latest@sha256:ccbbc30b4057f9364bf31e27e25c773f5f83cb3ed908bb2994cd2993fcbbad85

Scanned 1/1 images successfully, the clusterLocal flag for these images should now be false
```

Doublecheck:
```
$ ./detect.sh
Pulling Central metadata
{"version":"4.7.3","buildFlavor":"release","releaseBuild":true,"licenseStatus":"VALID"}

Searching for cluster local images

Found 0/93 images flagged as clusterLocal
```