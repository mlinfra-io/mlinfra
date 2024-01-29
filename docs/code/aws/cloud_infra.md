`cloud_infra` deploys MLOps `stack` on top of Cloud provider VMs.


## Complete example with all stacks

=== "Simple Deployment Configuration"
    ```yaml
    --8<-- "docs/examples/cloud_infra/complete/aws-complete.yaml"
    ```
=== "Advanced Deployment Configuration"
    ```yaml
    --8<-- "docs/examples/cloud_infra/complete/aws-complete-advanced.yaml"
    ```

## data_versioning

#### lakefs

=== "Simple Deployment Configuration"
    ```yaml
    --8<-- "docs/examples/cloud_infra/lakefs/aws-lakefs.yaml"
    ```
=== "Advanced Deployment Configuration"
    ```yaml
    --8<-- "docs/examples/cloud_infra/lakefs/aws-lakefs-advanced.yaml"
    ```

## experiment_tracking

#### mlflow

=== "Simple Deployment Configuration"
    ```yaml
    --8<-- "docs/examples/cloud_infra/mlflow/aws-mlflow.yaml"
    ```
=== "Advanced Deployment Configuration"
    ```yaml
    --8<-- "docs/examples/cloud_infra/mlflow/aws-mlflow-advanced.yaml"
    ```

#### wandb

=== "Simple Deployment Configuration"
    ```yaml
    --8<-- "docs/examples/cloud_infra/wandb/aws-wandb.yaml"
    ```
=== "Advanced Deployment Configuration"
    ```yaml
    --8<-- "docs/examples/cloud_infra/wandb/aws-wandb-advanced.yaml"
    ```


## orchestrator

#### prefect

=== "Simple Deployment Configuration"
    ```yaml
    --8<-- "docs/examples/cloud_infra/prefect/aws-prefect.yaml"
    ```
=== "Advanced Deployment Configuration"
    ```yaml
    --8<-- "docs/examples/cloud_infra/prefect/aws-prefect-advanced.yaml"
    ```

#### dagster

=== "Simple Deployment Configuration"
    ```yaml
    --8<-- "docs/examples/cloud_infra/dagster/aws-dagster.yaml"
    ```
=== "Advanced Deployment Configuration"
    ```yaml
    --8<-- "docs/examples/cloud_infra/dagster/aws-dagster-advanced.yaml"
    ```
