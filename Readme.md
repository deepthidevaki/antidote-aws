#firewall disable for minikube mount to work
ufw disable

#start minikube cluster
minikube start

#mount local directory with scripts to the minikube vm
minikube mount ./code/:/home/docker/code -v 10

#Generate template files
scripts/genConfig.sh #numdcs #numnodesindc

#deploy containers
kubectl create -f kube-config/


export AWS_ACCESS_KEY_ID=`aws configure get aws_access_key_id`
export AWS_SECRET_ACCESS_KEY=`aws configure get aws_secret_access_key`
#aws s3api create-bucket --bucket antidote-kube-cluster-state --region eu-central-1 --create-bucket-configuration LocationConstraint=eu-central-1
export NAME=antidotecluster.k8s.local
export KOPS_STATE_STORE=s3://antidote-kube-cluster-state
#aws ec2 describe-availability-zones eu-central-1
aws ec2 describe-availability-zones --region eu-central-1
kops create cluster --zones eu-central-1a ${NAME}
kops update cluster ${NAME} --yes

#Wait until the nodes are up (check ec2 console)
kubectl get nodes

kops validate cluster
kubectl get nodes


# Don't forget to delete
kops delete cluster --name ${NAME}
kops delete cluster --name ${NAME} --yes
