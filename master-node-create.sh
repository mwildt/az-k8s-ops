

while [[ $# -gt 0 ]]; do
  case $1 in
    -cn|--cluster-name)
      CLUSTER_NAME="$2"
      shift # past argument
      shift # past value
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      echo "Unknown paramer $1"
      exit 1
      ;;
  esac
done


if [ -v CLUSTER_NAME ]; then 
   echo "Cluster Name: $CLUSTER_NAME"
else
    echo "Bitte einen Cluster-Namen angeben"
    exit 1;
fi

mkdir -p .logs

#
# Anlegen der resource-groupe falls nicht vorhanden
#

RESOURCE_GROUP_NAME="$CLUSTER_NAME-RG"

SSHDIR=./.ssh
mkdir -p $SSHDIR

echo "check resource group $RESOURCE_GROUP_NAME"
az group show --name $RESOURCE_GROUP_NAME > /dev/null

# falls nicht -> rg wird angeleget.
if [ $? -ne 0 ]; then
    echo "create resource group with name $RESOURCE_GROUP_NAME"
    az deployment sub create  \
        --location germanywestcentral \
        --template-file azure/ressource-group.json \
        --parameters clusterName=$CLUSTER_NAME \
        --parameters rgName=$RESOURCE_GROUP_NAME
fi

#
# Erzeugen des VNets für das Cluster
#
echo "create VNET for cluster $CLUSTER_NAME" | tee -a ".logs/deploy.$CLUSTER_NAME.json"

az deployment group create -g $RESOURCE_GROUP_NAME \
    --template-file azure/virtual-network.json \
    --parameters rgName=$RESOURCE_GROUP_NAME \
    --parameters clusterName=$CLUSTER_NAME | tee .logs/deploy.$CLUSTER_NAME.json

if [ $? -ne 0 ]; then
    echo "*******************************************"
    echo "* D E P L O Y M E N T   F A I L E D   [STEP: VNET]"
    echo "*******************************************"
    exit $?
fi 

#
# Erzeugen ssh Key
#

KEY_NAME=${SSHDIR}/${RESOURCE_GROUP_NAME}_id_rsa
echo "Ssh-Key can be found here : $KEY_NAME" | tee -a .logs/deploy.$CLUSTER_NAME.json
# generate new ssh key

if test -f "$KEY_NAME"; then
    echo "key $KEY_NAME already exists. None will be created"
else 
    ssh-keygen -m PEM -t rsa -b 4096 -f $KEY_NAME
fi

# laden den public Key
PUBLIC_KEY_DATA=$(<${SSHDIR}/${RESOURCE_GROUP_NAME}_id_rsa.pub)

#
# Erzeugen der Master VM für das Cluster
#
echo "create Master VM for cluster $CLUSTER_NAME" | tee -a .logs/deploy.$CLUSTER_NAME.json

az deployment group create -g $RESOURCE_GROUP_NAME \
    --template-file azure/virtual-machine-master.json \
    --parameters rgName=$RESOURCE_GROUP_NAME \
    --parameters clusterName=$CLUSTER_NAME \
    --parameters publicKeyData="$PUBLIC_KEY_DATA" | tee -a .logs/deploy.$CLUSTER_NAME.json

if [ $? -ne 0 ]; then
    echo "*******************************************"
    echo "* D E P L O Y M E N T   F A I L E D   [STEP: Virtual Machine]"
    echo "*******************************************"
    exit $?
fi 

PUBLIC_IP=$(az vm show -d -g ${RESOURCE_GROUP_NAME} -n ${CLUSTER_NAME}-vm-master --query publicIps -o tsv)
SSH_BASE="ssh -i ${SSHDIR}/${RESOURCE_GROUP_NAME}_id_rsa $CLUSTER_NAME-admin@$PUBLIC_IP"
echo "vm is ready, run following to connect:"
echo $SSH_BASE


echo "use following commmands to configure the kubernetes-cluster:"
echo "1) Configure an Mount data Disks"
echo "$SSH_BASE sudo bash -s -- < ./scripts/disc-config.sh 0 /data"
echo "2) Install Kubernetes Componentes"
echo "$SSH_BASE sudo bash -s -- < ./scripts/kube-config.sh"
echo "3) Initialize and Confgure Kubernetes-Master-Node"
echo "$SSH_BASE sudo kubeadm init --apiserver-cert-extra-sans $PUBLIC_IP --pod-network-cidr=192.168.0.0/16"