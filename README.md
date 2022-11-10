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

## Deploy a test app

Let's deploy an NGINX app

## Deploy with Ingress

1. Navigate to the folder **kubernetes**.

    ```sh
    cd kubernetes
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

1. Deploy the container into your cluster.
  
    ```sh
    kubectl apply -f - <<EOF
    ---
    # Application to deploy
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: mynginx
      namespace: default
    spec:
      replicas: 3
      selector:
        matchLabels:
          app: mynginx
      template:   # create pods using pod definition in this template
        metadata:
          labels:
            app: mynginx
            tier: frontend
        spec:
          containers:
          - name: mynginx
            image: nginx
            imagePullPolicy: Always
            resources:
              requests:
                cpu: 250m     # 250 millicores = 1/4 core
                memory: 128Mi # 128 MB
              limits:
                cpu: 500m
                memory: 384Mi
            livenessProbe:
              httpGet:
                path: /healthcheck/
                port: 8080
              initialDelaySeconds: 3
              periodSeconds: 3
              failureThreshold: 2        

    ---
    # Service to expose frontend
    apiVersion: v1
    kind: Service
    metadata:
      name: mynginx
      namespace: default
      labels:
        app: mynginx
        tier: frontend
    spec:
        ports:
        - protocol: TCP
          port: 80
        selector:
          app: mynginx
          tier: frontend

    ---
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: mynginx-ingress
      namespace: default
      annotations:
        kubernetes.io/ingress.class: "public-iks-k8s-nginx"
        #kubernetes.io/ingress.class: "private-iks-k8s-nginx"
        nginx.ingress.kubernetes.io/ssl-redirect: "true"
    spec:
      tls:
        - hosts:
          - $IKS_INGRESS_URL
          secretName: $IKS_INGRESS_SECRET
      rules:
      - host: $IKS_INGRESS_URL
        http:
          paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: mynginx
                port:
                  number: 80
    EOF
    ```

1. Open a browser and check out the app with the following URL:

    ```sh
    open https://$IKS_INGRESS_URL
    ```

## Test performance

Let's use the k6 open-source load testing tool

1. Let's install k6

    ```sh
    brew install k6
    ```

1. Test an app

    ```sh
    k6 run - <<EOF
    import http from 'k6/http';

    export default function () {
      http.get('http://$IKS_INGRESS_URL');
    }
    EOF
    ```
