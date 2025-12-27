* The vpc needs to have a `nat gateway configured <https://repost.aws/questions/QU8XmyDQZOQkq9SSHoIM3tJg/setting-up-an-eks-node-group-on-a-private-subnet>`_ to allow the nodegroups to be able to find the eks cluster
* You can choose between creating a single nat gatway or one nat gateway per az.
