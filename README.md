## Using the release
Only works with Concourse versions under 5.0.0

1. Upload the release tarball to your bosh director 
  `bosh upload-release release.tgz`
1. Edit your deployment manifest
  1. Add the release
    ```yaml
    releases:
    - name: s3-iam-resource
      version: latest
    ```
  1. Add to the same instance group where you have the `concourse worker` job, the ordering of the jobs does not matter
    ```yaml
    - release: s3-iam-resource
      name: add-resource
    ```
1. Alternatively, use the provided ops file `ops/add-s3-iam-resource.yml`
1. Concourse will pick up the new resource automatically when it's deployed
1. Use the resource from your pipelines as `type: s3-iam`


## Building
- build the resource image and export the rootfs
  `make image`
- generate the release tarball
  - `make release` to generate a dev release tarball (default `RELEASE=release.tgz`)
  - `make final-release` to generate a final release tarball (default `RELEASE=release.tgz`, `VERSION=0.0.1`)
- uploads the release tarball to your bosh director (default `BOSH_ENV=vbox`)
  `make upload`


## Debugging
- The `add-resource` job installs `resource_metadata.json` and `rootfs/` to `/var/vcaps/packages/s3_iam_resource`
- Concourse on deployment will find every directory under `/var/vcaps/packages/*` that contains a `resource_metadata.json` file and load the `rootfs/` directory as the image for a resource
- If the resource is installed to some other path for whatever reason you can modify the properties of the `worker` job to specify the location of the `rootfs/` directory
  ```yaml
  release: concourse
  name: worker
  properties:
    ...
    additional_resource_types:
    - type: s3-iam
      image: path/to/your/resource/rootfs
  ```
  see https://bosh.io/jobs/worker?source=github.com/concourse/concourse-bosh-release&version=4.2.3#p%3dadditional_resource_types
