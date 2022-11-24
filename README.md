# iks-performance

## Provision the infrastructure

Estimated provisioning time: 40 mins

Let's use terraform to create two clusters in a VPC environment:

    * one standard cluster with 3 workers bx2.4x16 spread across 3 zones
    * one performance cluster with 2 edge workers and 3 workers bx2.4x16 spread across 3 zones

1. Let's use terraform to provision the full environment

    ```sh
    tf init
    tf plan -var-file="testing.auto.tfvars"
    tf apply -var-file="testing.auto.tfvars"
    ```

    > Note that the cluster performance has tainted worker nodes applied to the Edge workers
    https://cloud.ibm.com/docs/containers?topic=containers-edge#edge_workloads
    >
    > The taints are applied by terraform at the
    > provisioning time
    >    taints {
    >    key    = "dedicated"
    >    value  = "edge"
    >    effect = "NoExecute"
    > }

## Install the load testing app: Locust

  [Install locust](./kubernetes/locust/readme.md)

## Deploy the testing app

1. Navigate to the folder **kubernetes**.

    ```sh
    cd kubernetes/apps
    ```

1. Replace the cluster-name (including <>) with the the cluster name.

    ```sh
    export IKS_CLUSTER_NAME=<cluster-name>
    ```

1. View the details of a cluster

    ```sh
    ibmcloud ks cluster get -c $IKS_CLUSTER_NAME
    ```

1. Set the values of both the ingress subdomain and the ingress secret of your cluster. Those values will be used in the deployment yaml later.

    ```sh
    export IKS_INGRESS_URL=$(ic ks cluster get -c $IKS_CLUSTER_NAME | grep "Ingress Subdomain" | awk '{print tolower($3)}')
    export IKS_INGRESS_SECRET=$(ic ks cluster get -c $IKS_CLUSTER_NAME | grep "Ingress Secret" | awk '{print tolower($3)}')
    ```

1. Verify the values you set

    ```sh
    echo $IKS_INGRESS_URL
    echo $IKS_INGRESS_SECRET
    ```

    Output should be similar to this

    ```txt
    iks-325510-483cccd2f0d38128dd40d2b711142ba9-0000.eu-de.containers.appdomain.cloud
    iks-325510-483cccd2f0d38128dd40d2b711142ba9-0000
    ```

1. Modify the yaml app

1. Deploy the app into your cluster.
  
    ```sh
    kubectl apply -f my-service-nginx.yaml
    ```

1. Open a browser and check out the app with the following URL:

    ```sh
    open https://$IKS_INGRESS_URL
    ```

## Test performance

Let's use the k6 open-source load testing tool

1. Open the locust app

## Resources

    * [Tuning ALB performance](https://cloud.ibm.com/docs/containers?topic=containers-comm-ingress-annotations#perf_tuning)
    * [Setting a maximum number of upstream keepalive requests](https://cloud.ibm.com/docs/containers?topic=containers-comm-ingress-annotations#upstream-keepalive-requests)
    * [Scale ALBs](https://cloud.ibm.com/docs/containers?topic=containers-ingress-types#scale_albs)
