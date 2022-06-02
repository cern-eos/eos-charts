# SPS chart

### Helm Chart for the deployment of the XRootD Standard Proxy Service.

-----


### What for
This chart provides the ability to run an XRootD Standard Proxy Service to expose an EOS outside the k8s cluster.
- Pros: It removes the need for exposing the MGM and all the FTS to the outside of the k8s virtual networking, avoiding multihoming issues and requirement for port / hostNetwork availability on the hosts where EOS pods are deployed.
- Cons: It is a single point of failure and a bottleneck in terms of throughput. For deployments with specific requirements for throughput and availability, please consider deploying a [proxy cluster](https://xrootd.slac.stanford.edu/doc/dev51/pss_config.htm#_Toc50581499).

For more details on XRooD Proxy, check the [upstream documentation](https://xrootd.slac.stanford.edu/doc/dev51/pss_config.htm#_Toc50581497).


### Notes on Ingress
The Standard Proxy Service runs on L4 TCP (xrootd protocol), while the ingress is a L7 (http) facility.
To expose SPS to the outside world on TCP, it is required to patch the ingress controller, which is a cluster-wide configuration change.
Patching the ingress controller is not implemented in this Helm chart, but rather required manual configuration.

Below, we provide the recipe to configure (by patching) the nginx ingress controller,
which supports exposing an internal service on an external port via `--tcp-services-configmap`
([upstream documentation](https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/exposing-tcp-udp-services.md)).

The example considers to patch the nginx ingress controller:
- living in namespace 'ingress-nginx'
- to expose a service 'sps' in namespace 'default' on port '1094' protocol TCP
- on external port '1094'

1. Patch the ingress-controller configMap:
```sh
namespace="default"
service_name="sps"
host_port="1094"
container_port="1094"

target="$namespace/$service_name:$container_port"
json_patch=$(jq --null-input --compact-output \
  --arg host_port "$host_port" \
  --arg target "$target" \
  '{"data":{($host_port):($target)}}'
  )

kubectl -n ingress-nginx patch configmap tcp-services --patch=$json_patch
```

2. Patch the ingress-controller deployment
```sh
host_port="1094"
container_port="1094"

json_patch=$(jq --null-input --compact-output \
  --arg hp "$host_port" \
  --arg cp "$container_port" \
  '{"spec":{"template":{"spec":{"containers":[{"name":"controller","ports":[{"containerPort":($cp | tonumber),"hostPort":($hp | tonumber)}]}]}}}}' \
  )

kubectl -n ingress-nginx patch deployment ingress-nginx-controller --patch=$json_patch
```

