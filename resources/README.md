# Kubernetes Resource Management

Resource management in Kubernetes is essential for maintaining cluster stability, ensuring fair resource allocation, and preventing resource starvation. This guide covers how to configure, monitor, and optimize resources in your Kubernetes cluster.

## Table of Contents

- [Overview](#overview)
- [Resource Requests and Limits](#resource-requests-and-limits)
  - [Resource Requests](#resource-requests)
  - [Resource Limits](#resource-limits)
  - [Units](#units)
- [Quality of Service (QoS) Classes](#quality-of-service-qos-classes)
  - [Guaranteed](#guaranteed)
  - [Burstable](#burstable)
  - [BestEffort](#besteffort)
- [ResourceQuotas](#resourcequotas)
- [LimitRanges](#limitranges)
- [Monitoring Resource Usage](#monitoring-resource-usage)
- [Best Practices](#best-practices)
- [Examples](#examples)

## Overview

Kubernetes allows you to specify how much of each resource a container needs. The most common resources to specify are CPU and memory (RAM), but others are available as well.

## Resource Requests and Limits

### Resource Requests

A resource request specifies the minimum amount of a resource that a container needs. Kubernetes uses this information to decide which node to place the Pod on. The Pod will only be scheduled on a node that has enough resources available.

### Resource Limits

A resource limit specifies the maximum amount of a resource that a container can use. If a container exceeds its memory limit, it may be terminated. If a container exceeds its CPU limit, it will be throttled.

### Units

- **CPU** resources are measured in "millicores". One core is equivalent to 1000m. You can also use the decimal notation, such as 0.1 (equivalent to 100m).
- **Memory** resources are measured in bytes. You can express memory as a plain integer or as a fixed-point number with one of these suffixes: E, P, T, G, M, K, Ei, Pi, Ti, Gi, Mi, Ki.

Example:

```yaml
resources:
  requests:
    memory: "64Mi"
    cpu: "250m"
  limits:
    memory: "128Mi"
    cpu: "500m"
```

This means:
- The container requests a minimum of 0.25 CPU cores and 64 MiB of memory
- The container is limited to a maximum of 0.5 CPU cores and 128 MiB of memory

## Quality of Service (QoS) Classes

Kubernetes automatically assigns a QoS class to each Pod based on the resource requests and limits specified. This helps determine the order in which Pods are evicted when resources are low.

### Guaranteed

- **Criteria**: Every container in the Pod must have identical CPU and memory limits and requests.
- **Benefits**: Highest priority, least likely to be evicted under resource pressure.

### Burstable

- **Criteria**: At least one container in the Pod has a memory or CPU request, but the criteria for "Guaranteed" are not met.
- **Benefits**: Medium priority for eviction.

### BestEffort

- **Criteria**: None of the containers in the Pod have memory or CPU requests or limits specified.
- **Effects**: Lowest priority, first to be evicted under resource pressure.

## ResourceQuotas

ResourceQuotas allow you to limit the total resources consumed in a namespace. This is useful for multi-tenant clusters where you want to prevent one team from using all the cluster resources.

Example ResourceQuota:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: default
spec:
  hard:
    pods: "10"
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
```

## LimitRanges

LimitRanges set default, minimum, and maximum resource constraints for each container or Pod in a namespace.

Example LimitRange:

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: default-limit-range
spec:
  limits:
  - default:
      cpu: 500m
      memory: 256Mi
    defaultRequest:
      cpu: 200m
      memory: 128Mi
    type: Container
```

## Monitoring Resource Usage

You can monitor resource usage with:

```bash
# Get resource usage of pods
kubectl top pod

# Get resource usage of nodes
kubectl top node

# Get resource usage of a specific pod
kubectl top pod <pod-name>

# Get more detailed information about a pod's resource usage
kubectl describe pod <pod-name>
```

## Best Practices

1. **Always set resource requests**: This helps the scheduler place your Pod on an appropriate node.

2. **Set reasonable limits**: Set limits that are higher than requests but not so high that a single Pod could deplete all resources on a node.

3. **Monitor actual usage**: Use tools like Prometheus and Grafana or built-in tools like `kubectl top` to understand your actual resource usage.

4. **Be careful with CPU limits**: CPU limits can cause unexpected performance issues due to throttling. In some cases, it's better to use requests without limits for CPU.

5. **Optimize based on application behavior**: For memory-intensive applications, set appropriate memory requests and limits. For CPU-bound applications, ensure they have adequate CPU resources.

6. **Use namespaces and ResourceQuotas**: Organize your resources into namespaces and use ResourceQuotas to prevent any one application from consuming too many resources.

7. **Consider using Vertical Pod Autoscaler**: For automatically adjusting resource requests based on historical usage.

8. **Test under load**: Test your applications under load to understand their resource usage patterns.

## Examples

Here are example YAML files for working with resources:

1. [Pod with Resources](./pod-with-resources.yaml) - A basic pod with resource requests and limits
2. [Resource Quota](./resource-quota.yaml) - A namespace-level resource quota example
3. [Limit Range](./limit-range.yaml) - Default container resource limits for a namespace

To apply these examples:

```bash
kubectl apply -f pod-with-resources.yaml
kubectl apply -f resource-quota.yaml
kubectl apply -f limit-range.yaml
```

To check if resources are properly applied:

```bash
# For pods
kubectl describe pod resource-demo

# For ResourceQuota
kubectl describe quota compute-quota

# For LimitRange
kubectl describe limitrange default-limit-range
```