mlflow does not provide official support for helm chart (see [here](https://github.com/mlflow/mlflow/issues/6118))
The other two candidates for deploying mlflow using helm charts are
- [mlflow community chart](https://github.com/community-charts/helm-charts/tree/main/charts/mlflow)
- [bitnami helm chart](https://github.com/bitnami/charts/tree/main/bitnami/mlflow)

mlflow community chart has not been maintained for over a year now.
It has better api for deployment compared to bitnami chart.
Deploying bitnami chart was much pain; however i decided to go ahead with bitnami chart as the community chart was really outdated and had no official support.
