#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" > /dev/null && pwd )
CLUSTER_NAME="$(echo $USER | tr '[:upper:]' '[:lower:]')"

create_kind_cluster() {
    if [[ $(kind get clusters | grep $CLUSTER_NAME) ]]; then
        echo "👌 Kind cluster $CLUSTER_NAME already exists"
    else
        echo "⏳ Bootstrapping your Kubernetes cluster... Go grab a coffee ☕️"
        kind create cluster --name ${CLUSTER_NAME} --quiet --config ${SCRIPT_DIR}/kind/config.yaml
        if [[ $? -ne 0 ]]; then
            echo "❌ Failed to create your kubernetes cluster"
            exit 1
             
        else
           echo "🚀 Your Kubernetes cluster is ready"
        fi
    fi
}

helm_install() {
    # Release name override if provided
    if [ $# -gt 2 ]
    then
        RELEASE_NAME=$3
    else
        RELEASE_NAME=$1
    fi
    echo "⏳ Deploying ${RELEASE_NAME} in $2 namespace..."
    helm dependency update ${SCRIPT_DIR}/../kubernetes/$1 > /dev/null
    helm upgrade --install ${RELEASE_NAME} ${SCRIPT_DIR}/../kubernetes/$1 -f ${SCRIPT_DIR}/../kubernetes/$1/values.yaml --create-namespace --namespace $2 > /dev/null
    echo "🚀 ${RELEASE_NAME} is ready to use"
}

deploy_nginx_ingress_controller() {
    echo "⏳ Deploying NGINX ingress controller..."
    kubectl apply -f ${SCRIPT_DIR}/../kubernetes/nginx-ingress-controller/values.yaml > /dev/null
    kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=90s > /dev/null
    sleep 10
    echo "🚀 NGINX ingress controller is ready"
}

check_nginx_ingress_controller() {
    if [[ $(kubectl get ns ingress-nginx) ]]; then
        if [[ $(kubectl get pods -n ingress-nginx | wc -l)-1 -gt 0 ]]; then
            echo "👌 NGINX ingress controller already exists"
        else
            deploy_nginx_ingress_controller
        fi
    else
        deploy_nginx_ingress_controller
    fi
}

deploy_flat_manifests() {
    echo "⏳ Deploying $1 in $2 namespace..."
    (kubectl get ns | grep -qi $2) || kubectl create ns $2 > /dev/null
    kubectl apply -f ${SCRIPT_DIR}/../kubernetes/$1 -n $2 > /dev/null
    echo "🚀 $1 is ready to use"
}

# Deploy everything
create_kind_cluster
check_nginx_ingress_controller
helm_install mariadb data mariadb-1
helm_install mariadb data mariadb-2
