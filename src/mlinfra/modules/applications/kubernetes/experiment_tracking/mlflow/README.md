mlflow does not provide official support for helm chart (see [here](https://github.com/mlflow/mlflow/issues/6118))
The other two candidates for deploying mlflow using helm charts are
- [mlflow community chart](https://github.com/community-charts/helm-charts/tree/main/charts/mlflow)
- [bitnami helm chart](https://github.com/bitnami/charts/tree/main/bitnami/mlflow)

mlflow community chart has not been maintained for over a year now, and even though it had better api for deployment, we would be going forward with bitnami helm chart for now.
