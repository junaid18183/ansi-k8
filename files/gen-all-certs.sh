#All 
$PWD/cfssl/generate_ca.sh

#ETCD :
$PWD/cfssl/generate_server.sh k8s_etcd 172.31.27.23

scp ./secrets/ca.pem ec2-user@54.209.56.107:/home/ec2-user/ca.pem
scp ./secrets/k8s_etcd.pem ec2-user@54.209.56.107:/home/ec2-user/etcd.pem
scp ./secrets/k8s_etcd-key.pem ec2-user@54.209.56.107:/home/ec2-user/etcd-key.pem

ssh ec2-user@54.209.56.107 sudo mkdir -p /etc/kubernetes/ssl
ssh ec2-user@54.209.56.107 sudo mv /home/ec2-user/{ca,etcd,etcd-key}.pem /etc/kubernetes/ssl/.

ssh ec2-user@54.209.56.107 sudo  chown etcd:etcd /etc/kubernetes/ssl/etcd.*

#Master:
$PWD/cfssl/generate_server.sh k8s_master 172.31.27.23,54.209.56.107,10.3.0.1,kubernetes.default,kubernetes

scp ./secrets/ca.pem ec2-user@54.209.56.107:/home/ec2-user/ca.pem
scp ./secrets/k8s_master.pem ec2-user@54.209.56.107:/home/ec2-user/apiserver.pem
scp ./secrets/k8s_master-key.pem ec2-user@54.209.56.107:/home/ec2-user/apiserver-key.pem

$PWD/cfssl/generate_client.sh k8s_master

scp ./secrets/client-k8s_master.pem  ec2-user@54.209.56.107:/home/ec2-user/client.pem
scp ./secrets/client-k8s_master-key.pem  ec2-user@54.209.56.107:/home/ec2-user/client-key.pem

ssh ec2-user@54.209.56.107 sudo mkdir -p /etc/kubernetes/ssl
ssh ec2-user@54.209.56.107 sudo cp /home/ec2-user/{ca,apiserver,apiserver-key,client,client-key}.pem /etc/kubernetes/ssl/.
ssh ec2-user@54.209.56.107 rm /home/ec2-user/{apiserver,apiserver-key}.pem
ssh ec2-user@54.209.56.107 sudo mkdir -p /etc/ssl/etcd
ssh ec2-user@54.209.56.107 sudo mv /home/ec2-user/{ca,client,client-key}.pem /etc/ssl/etcd/.

#Worker:
$PWD/cfssl/generate_client.sh k8s_worker

scp ./secrets/ca.pem ec2-user@54.209.56.107:/home/ec2-user/ca.pem
scp ./secrets/client-k8s_worker.pem ec2-user@54.209.56.107:/home/ec2-user/worker.pem
scp ./secrets/client-k8s_worker-key.pem ec2-user@54.209.56.107:/home/ec2-user/worker-key.pem

ssh ec2-user@54.209.56.107 sudo mkdir -p /etc/kubernetes/ssl
ssh ec2-user@54.209.56.107 sudo cp /home/ec2-user/{ca,worker,worker-key}.pem /etc/kubernetes/ssl/.
ssh ec2-user@54.209.56.107 sudo mkdir -p /etc/ssl/etcd/
ssh ec2-user@54.209.56.107 sudo mv /home/ec2-user/{ca,worker,worker-key}.pem /etc/ssl/etcd/.
