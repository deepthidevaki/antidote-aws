numdcs=$1
numnodes=$2
templatedir='kube-templates'
gendir='kube-configs'
rm $gendir/*
for i in `seq 1 ${numdcs}`; do
    dcnum=$i
    sed -e "s/\${N}/${dcnum}/" ${templatedir}/antidote-dc-N-service.yaml > ${gendir}/antidote-dc-${dcnum}-service.yaml
    sed -e "s/\${N}/${dcnum}/" -e "s/\${Replicas}/${numnodes}/" ${templatedir}/antidote-dc-N-statefulset.yaml > ${gendir}/antidote-dc-${dcnum}-statefulset.yaml
done

sed -e "s/\${N}/${numdcs}/" -e "s/\${Replicas}/${numnodes}/" ${templatedir}/antidote-setup.yaml > ${gendir}/antidote-setup.yaml
