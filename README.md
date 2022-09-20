# Pattern - Using Azure Files on AKS

This is a demo repo to deploy an Azure Kubernetes Service cluster with a PVC on Azure Files (Dynamically). 

Please refer to this documentation for more details: [Dynamically create and use a persistent volume with Azure Files in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/azure-files-dynamic-pv)

### Steps to run this demo

To install the full solution:

1. Change the ```run.rc``` file to reflect your environment
2. Run:
```bash
./run.sh -x install
```

To remove the entire deployment:

1. Run:

```bash
./run.sh -x delete
```

Usage:

```bash
$ ./run.sh 
usage: run.sh [options]
    -x  action to be executed.
    
Possible verbs are:
    install        deploy all resources.
    delete         delete all resources.
    dry-run        tries the current Bicep deployment against Azure but doesnt deploy (what-if). 

    Demo components:
    
    install-demo  only installs the demo on the cluster.
    delete-demo   removes the demo from the cluster.
    show-demo     shows the demo from the cluster.
```
