# eosxd chart
=====

Helm Chart for the deployment of the EOS Fusex mount.


### What for
This chart provides the ability to run an EOS Fusex mount in a pod.
The EOS mount is exposed on the host via a bind mount so that other conatiners (or processes running on the host) can access it. The default path on the host is `/eos`.
The chart deploys EOS Fusex clients as a daemonSet that will run on each host of the cluster or on a subset of nodes identified by custom labels.


### Add the eos chart repository
Configure helm by adding the eos chart repository to your repository list
```bash
helm repo add eos https://registry.cern.ch/chartrepo/eos
helm repo update 
```


### Pull the eosxd chart
```bash
helm pull eos/eosxd --untar
```
This will create a folder named `eosxd` in the current directory with the uncompressed chart


### Install the chart
After having configured the relevant bits (see below), install the chart and the deploy eosxd in your cluster with
```bash
helm install eosxd eosxd/
```


### Basic configuration options
Configuration options are accessible via the `values.yaml` file in the chart root directory.
Basic requirements to connect to an existing eos instance are:
  - eosxd.config.eos\_mgm\_alias: The fully qualified domain name of the MGM of the instance to connect to;
  - eosxd.config.auth: The authetication method of the client with the MGM. The default is SSS (simple shared secret), which requires providing the instance keytab to the fusex client.
  - eosxd.keytab: The keytab used by SSS authentication.


### Deploying eosxd on a subset of nodes
If the access to EOS is required by only a subset of nodes of your cluster, it is possible to restrict the deployment of the eosxd pod to these nodes only.
  1. Enable the node selection by setting `podAssignment.enableNodeSelector: true`.
  2. Define at least one custom label under `customLabels` in the form of key:value. An example is provided. 
  3. Label the nodes in your cluster according to the chosen customLabels.


### SSS authentication and keytabs
To use SSS authentication, this must be enabled in the instance configuration and the keytab must be _forwardable_ (i.e., it ends with a '+' sign).
The keytab is passed to the eosxd pod as a kubenretes secret. It must be base64-encoded in `values.yaml`.


### Configuring eosxd as a trusted gateway
In some cases, it might be required to register the eosxd client as a trusted gateway. This must be done on the MGM with the command `eos vid set add gateway <hostname> [krb5|gsi|sss|unix|https|grpc]`.
As kubernetes pods do not use the host network by default, their network identifier as seen by the MGM might unknown and/or change over time. To circumvent this problem, it is recommended to set:
  - eosxd.hostNetwork: true
  - eosxd.dnsPolicy: ClusterFirstWithHostNet

