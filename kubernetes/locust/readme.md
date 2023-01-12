# Locust

[Locust](https://locust.io/) is used in this project to run load tests against our applications and to retrieve the maximum requests per second under different circumstances. 

## Deploy Locust

1. Provision a separate cluster

- Deployed in a 5 worker node cluster with flavor b3c.4x16
- Deploying Locust in a separate cluster avoids resource conflicts between applications

1. Retrieve the cluster ingress domain

    ```sh
    ibmcloud ks cluster get -c <your-cluster-name>
    ```

1. Replace the `<host>` in `locust-master.yaml` with your Ingress domain by something like `locust.<subdomain>`

1. Deploy Locust by using kubectl

    ```sh
    kubectl apply -f locust-master.yaml
    kubectl apply -f locust-slave.yaml
    kubectl apply -f locust-cm.yaml
    ```
