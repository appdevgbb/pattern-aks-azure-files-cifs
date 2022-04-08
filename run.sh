#!/usr/bin/env bash
set -Eo pipefail

source run.rc
source common/demo.subr
source common/azure.subr
source common/utils.subr

########################################################################################
AZURE_LOGIN=0
PURGE=1
########################################################################################
trap exit SIGINT SIGTERM

__usage="
    -x  action to be executed.
    
Possible verbs are:
    install        deploy all resources.
    delete         delete all resources.
    dry-run        tries the current Bicep deployment against Azure but doesn't deploy (what-if). 

    Demo components:
    
    install-demo  only installs the demo on the cluster.
    delete-demo   removes the demo from the cluster.
    show-demo     shows the demo from the cluster.
"
usage() {
  echo "usage: ${0##*/} [options]"
  echo "${__usage/[[:space:]]/}"
  exit 1
}

# execute as the last part of the setup process
afterboot() {

  read -r -d '' COMPLETE_MESSAGE <<EOM
****************************************************
[demo] - Deployment Complete! 

Cluster connection info: 
  export KUBECONFIG=${PREFIX}-aks.kubeconfig
  kubectl get nodes
****************************************************
EOM

  echo "$COMPLETE_MESSAGE"
}

do_install_demo() {
  demo_do create sc
  demo_do create pvc
  demo_do create pod
}

do_delete_demo() {
  echo "removing demo from the Cluster"
  demo_do delete pod
  demo_do delete pvc
  demo_do delete sc
}

do_show_demo() {
  cmd kubectl get pvc my-azurefile
  cmd kubectl describe pod mypod
}

do_delete_azure_resources() {
  echo "removing resources in Azure"
  cmd az group delete --name "${RG_NAME}" --no-wait --yes
  echo "removing logs"
  rm -rf ./outputs
}

# install the Azure resources and demo
do_install() {
  rg_create
  cluster_deploy
  cluster_logs
  aks_get_credentials
  get_deployment_info
  do_install_demo
  afterboot
}

# removes the Azure resources and demo
do_delete() {
  do_delete_azure_resources
}

do_dry_run() {
  # create a random rg so we can dry-run the deployment
  RG_NAME=$RG_NAME-$RANDOM
  rg_create

  create_ssh_keys
  cluster_dry_run
  do_delete_azure_resources
}

exec_case() {
  local _opt=$1

  case ${_opt} in
  install)       do_install ;;
  delete)        do_delete ;;
  install-demo)  do_install_demo ;;
  delete-demo)   do_delete_demo ;;
  show-demo)     do_show_demo ;;
  dry-run)       do_dry_run ;;
  *)             usage ;;
  esac
  unset _opt
}

main() {
  while getopts "x:" opt; do
    case $opt in
    x)
      exec_flag=true
      EXEC_OPT="${OPTARG}"
      ;;

    *) usage ;;
    esac
  done
  shift $(($OPTIND - 1))

  if [ $OPTIND = 1 ]; then
    usage
    exit 0
  fi

  # process actions
  if [[ "${exec_flag}" == "true" ]]; then
    # check if we are logged first
    check_for_azure_login
    exec_case "${EXEC_OPT}"
  fi 
}

main "$@"
exit 0