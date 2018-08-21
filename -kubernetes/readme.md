# Kubernetes cluster in GKE

## Pre Requirements

Installed and configured `gcloud` CLI and `kubectl`

Kubernetes cluster created in GKE.

MySQL DB create in gCloud.

Created `service-account.json` file for the `sql-proxy` container like it described [here](https://cloud.google.com/sql/docs/mysql/connect-kubernetes-engine#2_create_a_service_account)

## Configuration

Put `service-account.json` to kubernetes secrets by executing the following command:

```bash
kubectl create secret generic mysql-instance-credentials \
--from-file=credentials.json=service-account.json
```

Create secrets for the application:

```bash
kubectl create secret generic simple-app-secrets \
--from-literal=username=$MYSQL_PASSWORD \
--from-literal=password=$MYSQL_PASSWORD \
--from-literal=database-name=$MYSQL_DB_NAME \
--from-literal=secretkey=$SECRET_RAILS_KEY
```

Don’t forget to replace values or set environment variables with your values.

Open `deployment.yaml` file and replace connection string to your DB instance `"-instances=test-d6bf8:us-central1:simple-db=tcp:3306"`, check image for your app.

## Ship it

It is time to ship it to GKE cluster!

Apply migrations: `kubectl apply -f rake-tasks-job.yaml`

Create service, deployment and HPA: `kubectl apply -f deployment.yaml`

Check pods: `kubectl get pods -w`, they should look like:

```bash
NAME                      READY     STATUS    RESTARTS   AGE
sample-799bf9fd9c-86cqf   2/2       Running   0          1m
sample-799bf9fd9c-887vv   2/2       Running   0          1m
sample-799bf9fd9c-pkscp   2/2       Running   0          1m
```

### Ingress

1. Create static IP: `gcloud compute addresses create sample-ip --global`
2. Create ingress: `kubectl apply -f ingress.yaml`
3. Check ingress has been created and grab IP: `kubectl get ingress -w`
4. (optional) Create domain/subdomain for your application.

## CI/CD

Create integration with the [circle-ci](http://circleci.com/)

Configure project in circle-ci. Create environment variables: `GCLOUD_SERVICE_KEY` (you should create service-account with the roles: full access to the GCR and GKE), `GOOGLE_PROJECT_ID` (you can find it at home page of the gCloud console), `GOOGLE_COMPUTE_ZONE` (zone for your GKE cluster) and `GOOGLE_CLUSTER_NAME` (GKE cluster name).
