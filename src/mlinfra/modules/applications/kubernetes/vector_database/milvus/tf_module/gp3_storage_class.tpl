apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-gp3-sc
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: ebs.csi.aws.com
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
allowedTopologies:
  - matchLabelExpressions:
      # check which one is used
      - key: topology.ebs.csi.aws.com/zone
        values:
        %{~ for az in availability_zones ~}
          - ${az}
        %{~ endfor ~}
      - key: failure-domain.beta.kubernetes.io/zone
        values:
          - us-east-1a
parameters:
  type: gp3
