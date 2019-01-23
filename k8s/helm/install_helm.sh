#Download da versão 1.12
wget https://storage.googleapis.com/kubernetes-helm/helm-v2.12.0-linux-amd64.tar.gz

#Descompactar
tar -xvf helm-v2.12.0-linux-amd64.tar.gz

#Mover para o caminho executável
sudo mv l*/helm /usr/local/bin/.

#Inicializar o Helm
helm init

#Atualizar o helm
helm init --upgrade

#Adicionar as credenciais kubernetes
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule \
   --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy \
   -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
