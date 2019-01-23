usage()
{
    cat <<END
deploy.sh: deploys eShopOnContainers application to Kubernetes cluster
Parameters:
  -r | --registry <container registry> 
    Specifies container registry (ACR) to use (required), e.g. myregistry.azurecr.io
  --docker-user <docker user> 
    Especifica o usuario docker
  --docker-password <docker password> 
    Especifica a senha do usuario docker
  --external-DNS <dns externo>
    Especifica um IP para expor a aplicacao
  -t | --tag <image tag>
    Tag da aplicacao
  -h | --help
    Displays this help text and exits the script
It is assumed that the Kubernetes AKS cluster has been granted access to ACR registry.
For more info see 
https://docs.microsoft.com/en-us/azure/container-registry/container-registry-auth-aks
WARNING! THE SCRIPT WILL COMPLETELY DESTROY ALL DEPLOYMENTS AND SERVICES VISIBLE
FROM THE CURRENT CONFIGURATION CONTEXT.
It is recommended that you create a separate namespace and confguration context
for the eShopOnContainers application, to isolate it from other applications on the cluster.
For more information see https://kubernetes.io/docs/tasks/administer-cluster/namespaces/
You can use eshop-namespace.yaml file (in the same directory) to create the namespace.
END
}

appName="my-eshop"
deployInfrastructure=true
clean=true
aksName=""
aksRg=""
useLocalk8s=true
ingressValuesFile="ingress_values.yaml"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -r | --registry )
        container_registry="$2"; shift 2 ;;
    -u | --docker-user )
        docker_user="$2"; shift 2 ;;
    -p | --docker-password )
        docker_password="$2"; shift 2 ;;
    -e | --external-DNS )
        external_dns="$2"; shift 2 ;;
    -t | --tag )
        image_tag="$2"; shift 2 ;;
    -h | --help )
        usage; exit 1 ;;
    *)
        echo "Unknown option $1"
        usage; exit 2 ;;
  esac
done

#if [[ ! $container_registry ]]; then
#    echo 'Container registry must be specified (e.g. myregistry.azurecr.io)'
#    echo ''
#    usage
#    exit 3
#fi

#if [[ ! $docker_user ]]; then
#    echo "Usuário docker deve ser especificado"
#    echo ''
#    usage
#    exit 3
#fi

#if [[ ! $docker_password ]]; then
#    echo "Senha do usuário docker deve ser especificado"
#    echo ''
#    usage
#    exit 3
#fi

if [[ ! $external_dns ]]; then
    echo "DNS externo deve ser especificado"
    echo ''
    #$external_dns="127.0.0.1"
    usage
    exit 3
fi

if [[ $clean ]]; then
    echo "Limpando as versões anteriores..."
    helm delete --purge $(helm ls -q)
    echo "Versões anteriores deletadas"
fi

if [[$useLocalk8s==true]]; then
    $ingressValuesFile="ingress_values_dockerk8s.yaml"
fi


export TAG=$image_tag

infras=("sql-data" "nosql-data" "rabbitmq" "keystore-data" "basket-data")
charts=("eshop-common" "apigwmm" "apigwms" "apigwwm" "apigwws" "basket-api" "catalog-api" "identity-api" "locations-api" "marketing-api" "mobileshoppingagg" "ordering-api" "ordering-backgroundtasks" "ordering-signalrhub" "payment-api" "webmvc" "webshoppingagg" "webspa" "webstatus")

for infra in "${infras[@]}" ; do
    echo "Instalando infreaestrutura: $infra"
    helm install --values app.yaml --values inf.yaml --values $ingressValuesFile --set app.name=$appName --set inf.k8s.dns=$external_dns --name="$appName-$infra" "$infra"
done

#for chart in "${charts[*]}" ; do
#    echo "Instalando chart: $chart"
#    helm install  --values app.yaml --values inf.yaml --values $ingressValuesFile --set app.name=$appName --set inf.k8s.dns=$external_dns --set image.tag=$image_tag --set image.pullPolicy=Always --name="$appName-$chart" $chart
#done

helm install --values app.yaml --values inf.yaml --values $ingressValuesFile --set app.name=$appName --set inf.k8s.dns=$external_dns --set image.tag="eshop.common" --set image.pullPolicy=Always --name="$appName-eshop-common" "eshop-common"
helm install  --values app.yaml --values inf.yaml --values $ingressValuesFile --set app.name=$appName --set inf.k8s.dns=$external_dns --set image.tag="ocelotapigw" --set image.pullPolicy=Always --name="$appName-apigwms" "apigwms"
helm install  --values app.yaml --values inf.yaml --values $ingressValuesFile --set app.name=$appName --set inf.k8s.dns=$external_dns --set image.tag="ocelotapigw" --set image.pullPolicy=Always --name="$appName-apigwmm" "apigwmm"
helm install  --values app.yaml --values inf.yaml --values $ingressValuesFile --set app.name=$appName --set inf.k8s.dns=$external_dns --set image.tag="ocelotapigw" --set image.pullPolicy=Always --name="$appName-apigwwm" "apigwwm"
helm install  --values app.yaml --values inf.yaml --values $ingressValuesFile --set app.name=$appName --set inf.k8s.dns=$external_dns --set image.tag="ocelotapigw" --set image.pullPolicy=Always --name="$appName-apigwws" "apigwws"
helm install  --values app.yaml --values inf.yaml --values $ingressValuesFile --set app.name=$appName --set inf.k8s.dns=$external_dns --set image.tag="basket.api" --set image.pullPolicy=Always --name="$appName-basket-api" "basket-api"
helm install  --values app.yaml --values inf.yaml --values $ingressValuesFile --set app.name=$appName --set inf.k8s.dns=$external_dns --set image.tag="catalog.api" --set image.pullPolicy=Always --name="$appName-catalog-api" "catalog-api"
helm install  --values app.yaml --values inf.yaml --values $ingressValuesFile --set app.name=$appName --set inf.k8s.dns=$external_dns --set image.tag="identity.api" --set image.pullPolicy=Always --name="$appName-identity-api" "identity-api"
helm install  --values app.yaml --values inf.yaml --values $ingressValuesFile --set app.name=$appName --set inf.k8s.dns=$external_dns --set image.tag="locations.api" --set image.pullPolicy=Always --name="$appName-locations-api" "locations-api"
helm install  --values app.yaml --values inf.yaml --values $ingressValuesFile --set app.name=$appName --set inf.k8s.dns=$external_dns --set image.tag="marketing.api" --set image.pullPolicy=Always --name="$appName-marketing-api" "marketing-api"
helm install  --values app.yaml --values inf.yaml --values $ingressValuesFile --set app.name=$appName --set inf.k8s.dns=$external_dns --set image.tag="mobileshoppingagg" --set image.pullPolicy=Always --name="$appName-mobileshoppingagg" "mobileshoppingagg"
helm install  --values app.yaml --values inf.yaml --values $ingressValuesFile --set app.name=$appName --set inf.k8s.dns=$external_dns --set image.tag="ordering.api" --set image.pullPolicy=Always --name="$appName-ordering-api" "ordering-api"
helm install  --values app.yaml --values inf.yaml --values $ingressValuesFile --set app.name=$appName --set inf.k8s.dns=$external_dns --set image.tag="ordering.backgroundtasks" --set image.pullPolicy=Always --name="$appName-ordering-backgroundtasks" "ordering-backgroundtasks"
helm install  --values app.yaml --values inf.yaml --values $ingressValuesFile --set app.name=$appName --set inf.k8s.dns=$external_dns --set image.tag="ordering-signalrhub" --set image.pullPolicy=Always --name="$appName-ordering-signalrhub" "ordering-signalrhub"
helm install  --values app.yaml --values inf.yaml --values $ingressValuesFile --set app.name=$appName --set inf.k8s.dns=$external_dns --set image.tag="payment.api" --set image.pullPolicy=Always --name="$appName-payment-api" "payment-api"
helm install  --values app.yaml --values inf.yaml --values $ingressValuesFile --set app.name=$appName --set inf.k8s.dns=$external_dns --set image.tag="webmvc" --set image.pullPolicy=Always --name="$appName-webmvc" "webmvc"
helm install  --values app.yaml --values inf.yaml --values $ingressValuesFile --set app.name=$appName --set inf.k8s.dns=$external_dns --set image.tag="webshoppingagg" --set image.pullPolicy=Always --name="$appName-webshoppingagg" "webshoppingagg"
helm install  --values app.yaml --values inf.yaml --values $ingressValuesFile --set app.name=$appName --set inf.k8s.dns=$external_dns --set image.tag="webspa" --set image.pullPolicy=Always --name="$appName-webspa" "webspa"
helm install  --values app.yaml --values inf.yaml --values $ingressValuesFile --set app.name=$appName --set inf.k8s.dns=$external_dns --set image.tag="webstatus" --set image.pullPolicy=Always --name="$appName-webstatus" "webstatus"



echo "Helm charts instalado"
