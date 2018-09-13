# Pelias Kubernetes Configuration

This repository contains Kubernetes configuration files to create a production ready instance of Pelias.

This configuration is meant to be run on Kubernetes using real hardware or full sized virtual
machines in the cloud. Technically it could work on a personal computer with
[minikube](https://github.com/kubernetes/minikube) but it would require a machine with lots of RAM:
24GB or more.

**Note:** These are very early stage, and are being rapidly changed and improved. We welcome
feedback from anyone who has used them.

## Setup

First, set up a Kubernetes cluster however works best for you. A popular choice is to use
[kops](https://github.com/kubernetes/kops) on AWS. The [Getting Started on AWS Guide](https://github.com/kubernetes/kops/blob/master/docs/aws.md) is a good starting point.

### Sizing the Kubernetes cluster

A working Pelias cluster contains the following services:
* Pelias API (requires about 256MB of RAM) (**required**)
* Libpostal Service (requirs about 2GB of RAM) (**required**)
* Placeholder Service (Requires 512MB of RAM) (**strongly recommended**)
* Point in Polygon (PIP) Service (Requires 6GB of RAM) (**required for reverse geocoding**)
* Interpolation Service (requires ~2GB of RAM)

Some of the following importers will additionally have to be run to initially populate data
* Who's on First (requires about 1GB of RAM)
* OpenStreetMap (requires between 0.25GB and 6GB of RAM depending on import size)
* OpenAddresses (requires 1GB of RAM)
* Geonames (requires ~0.5GB of RAM)
* Polylines (requires 1GB of RAM)

Finally, the importers require the PIP service to be running

Use the[data sources](https://mapzen.com/documentation/search/data-sources/) documentation to decide
which importers to be run.

Importers can be run in any order, in parallel or one at a time.

This means around 10GB of RAM is required to bring up all the services, and up to another 15GB of RAM is needed to
run all the importers at once. 2 instances with 8GB of RAM each is a good starting point just for
the services.

If using kops, it defaults to `t2.small` instances, which are far too small (they only have 2GB of ram).

You can edit the instance types using `kops edit ig nodes` before starting your cluster. `m4.large` is a good choice to start.

## Elasticsearch

Elasticsearch is used as the primary datastore for Pelias data. As a powerful database with built in
scalability and replication abilities, it is not currently well suited for running in Kubernetes.

Instead, it's preferable to create "regular" instances in your cloud provider or on your own
hardware. To help with this, the `elasticsearch/` directory in this repository contains tools for
setting up a production ready, Pelias compatible Elasticsearch cluster. It uses
[Terraform](http://terraform.io/) and [Packer](http://packer.io/) to do this. See the directory
[README](./elasticsearch/README.md) for more details.

# debuging 'init containers'

sometimes an 'init container' fails to start, you can view the init logs:

```bash
# kubectl logs {{pod_name}} -c {{init_container_name}}
kubectl logs geonames-import-4vgq3 -c geonames-download
```

# opening a bash prompt in a running container

it can be useful to open a shell inside a running container for debugging:

```bash
# kubectl exec -it {{pod_name}} -- {{command}}
kubectl exec -it pelias-pip-3625698757-dtzmd -- /bin/bash
```

# Helm Chart Configuration
The following table lists common configurable parameters of the chart and
their default values. See values.yaml for all available options.

|       Parameter                        |           Description                       |                         Default                     |
|----------------------------------------|---------------------------------------------|-----------------------------------------------------|
| `elasticsearch.host`                   | Elasticsearch hostname                      | `elasticsearch-service`                                              |
| `elasticsearch.port`                   | Elasticsearch access port                   | `9200`                                              |
| `elasticsearch.protocol`               | Elasticsearch access protocol               | `http`                                              |
| `elasticsearch.auth`                   | Elasticsearch authentication `user:pass`    | `-`                                              |
| `pip.enabled`                          | Whether to enable pip service               | `true`                                              |
| `pip.host`                             | Pip service url                             | `http://pelias-pip-service:3102/`                   |
| `pip.pvc.create`                       | To use a custom PVC                         | `-`                                                 |
| `pip.pvc.name`                         | Name of the PVC                             | `-`                                                 |
| `pip.pvc.storageClass`                 | Storage Class to use for PVC	               | `-`                                                 |
| `pip.pvc.storage`                      | Amount of space to claim for PVC	           | `-`                                                 |
| `pip.pvc.annotations`                  | Storage Class annotation for PVC	           | `-`                                                 |
| `pip.pvc.accessModes`                  | Access mode to use for PVC      	           | `-`                                                 |
| `interpolation.enabled`                | Whether to enable interpolation service     | `false`                                             |
| `interpolation.host`                   | Pip service url                             | `http://pelias-interpolation-service:3000/`           |
| `interpolation.pvc.create`             | To use a custom PVC                         | `-`                                                 |
| `interpolation.pvc.name`               | Name of the PVC                             | `-`                                                 |
| `interpolation.pvc.storageClass`       | Storage Class to use for PVC	               | `-`                                                 |
| `interpolation.pvc.storage`            | Amount of space to claim for PVC	           | `-`                                                 |
| `interpolation.pvc.annotations`        | Storage Class annotation for PVC	           | `-`                                                 |
| `interpolation.pvc.accessModes`        | Access mode to use for PVC      	           | `-`                                                 |