1. Generate template files  
    numdcs = number of Antidote data centers
    numnodesindc = number of nodes per data center
`scripts/genConfig.sh #numdcs #numnodesindc`

2. Set up the environment for kops  
```
export AWS_ACCESS_KEY_ID=\`aws configure get aws_access_key_id\`  
export AWS_SECRET_ACCESS_KEY=\`aws configure get aws_secret_access_key\`
```  

Create s3 bucket only once  
```
aws s3api create-bucket --bucket antidote-kube-cluster-state --region eu-central-1 --create-bucket-configuration LocationConstraint=eu-central-1
```  
Give a name for the cluster  
```
export NAME=antidotecluster.k8s.local
export KOPS_STATE_STORE=s3://antidote-kube-cluster-state
aws ec2 describe-availability-zones --region eu-central-1
```  

3. Create cluster in AWS
We can create a basic cluster using the following commands.
```
kops create cluster --zones eu-central-1a ${NAME}
kops update cluster ${NAME} --yes
```

Wait until the nodes are up (check ec2 console)

```
kops validate cluster
kubectl get nodes
```

4. If the cluster is created and ready, we can now deploy the antidote containers  
`kubectl create -f kube-configs/ `  
Wait for the pods to be up and running. Then starts the script to join antidote clusters.
```
kubectl create -f kube-config-setup/
```

Check the status by
`kubectl log antidote-setup-0 `

Now the antidote setup is completed.

Next step is to run benchmarks.

5 Don't forget to delete cluster
```
kops delete cluster --name ${NAME}
kops delete cluster --name ${NAME} --yes
```
