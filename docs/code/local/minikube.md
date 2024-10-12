`minikube` deploys MLOps `stack` on top of [minikube cluster](https://minikube.sigs.k8s.io/) on your machine. Please ensure that docker is installed and running on your machine, along with the latest version of minikube.


#### Complete

===+ "Simple Deployment Configuration"
    ```yaml
    --8<-- "docs/examples/local/minikube.yaml"
    ```
=== "Advanced Deployment Configuration"
    ```yaml
    --8<-- "docs/examples/local/minikube-advanced.yaml"
    ```

- Once the stacks have been deployed, there is one last step that allows the deployed stacks to be accessed on your local machine. You need to open a new terminal window and find the minikube profile that you're using `minikube profile list` and run `minikube tunnel --profile='<minikube-profile>'` to allow the services to be accessible on the local instance.
