# LakeFS Important Notes

## Bucket settings

- The bucket is created on creation time along with LakeFS server and is added to the instance profile of EC2 instance so that it can communicate with the server without needing any credentials.
- Only one bucket can be used as a source of truth by LakeFS server and all the repositories created underneath it.
- In order to separate different repositories in the S3 bucket, you can use a hierarchical directory model to create a distinct folder for every repository.
- The bucket name can be passed as a parameter in the `yaml` config file. Please use the same bucket name when creating the repository followed by repository specific directory structure. You cannot refer any other bucket after creation as that bucket does not exist in the EC2 instance's scope of actions and wouldn't be accessible.
