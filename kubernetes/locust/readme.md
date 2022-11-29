# Locust
[Locust](https://locust.io/) is used in this project to run load tests against our applications and to retrieve the maximum requests per second under different circumstances. 

## Deploy Locust

1. Provision a separate cluster

- Deployed in a 5 worker node cluster with flavor b3c.4x16
- Deploying Locust in a separate cluster avoids resource conflicts between applications

2. Retrieve the cluster ingress domain
- You can extract the IBM Cloud IKS ingress domain with the command described [here](https://cloud.ibm.com/docs/containers?topic=containers-ingress-types#alb-com-create-ibm-domain)
- Include the subdomain in `locust-master.yaml` Ingress object with something like `locust.<subdomain>`

3. Deploy Locust
- Deploy by using kubectl:
```
kubectl apply -f locust-master.yaml
kubectl apply -f locust-slave.yaml
kubectl apply -f locust-cm.yaml
```