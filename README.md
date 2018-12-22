# elasticsearch

Terraform files for deploying an ES cluster in AWS, and a node.js script for populating ES with a dataset.

## Creating the ES Cluster

The ES cluster is deployed via Terraform. To create the cluster change into the `terraform` directory and run the following commands to initialise terraform and deploy the cluster:

```bash
$ terraform init
$ terraform apply
```

The required variables can either be entered individually when prompted in the terminal, or a var file can be passed in to the `terraform apply` command, i.e. `terraform apply -var-file=variables.tfvars`.

A list of the modules variables can be found in `variables.tf`, along with descriptions and any default values.

Once the cluster has been deployed, two URLs will be displayed.

#### kibana
This URL can be accessed in your browser to visualise the data in the ES cluster


#### elasticsearch
This URL is used when communicating with the cluster. It is required for the next step.


## Populating the ES Cluster

To populate the ES cluster, the node.js script is run. From the root of the project, run the following commands:

```bash
$ npm i
$ ES_ENDPOINT="<elasticsearch endpoint obtained in last step>" node index.js
```

This will connect to the ES cluster, check it's health, and then create an populate an ES index with the dataset.
