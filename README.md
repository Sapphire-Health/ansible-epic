# Ansible Azure Inventory

## Create venvs for Azure and AWS
```
mkdir -p ~/venv/aws
mkdir -p ~/venv/azure
python3 -m venv ~/venv/aws
python3 -m venv ~/venv/azure
```

## Activate venv and Install Deps (AWS)
```
source ~/venv/aws/bin/activate
# set vscode ansible.python.activationScript to ~/venv/aws/bin/activate
pip3 install botocore boto3 ansible-lint
ansible-galaxy collection install amazon.aws community.aws ansible.utils community.windows ansible.windows ansible.posix community.general
# deactivate
```

## Activate venv and Install Deps (Azure)
```
source ~/venv/azure/bin/activate
# set vscode ansible.python.activationScript to ~/venv/azure/bin/activate
pip3 install ansible-lint
ansible-galaxy collection install azure.azcollection community.aws ansible.utils community.windows ansible.windows ansible.posix community.general
pip3 install -r ~/.ansible/collections/ansible_collections/azure/azcollection/requirements.txt
# deactivate
```

### Install Ansible Roles and Collections (DEPRECATED STEP)
```
# ansible-galaxy collection install -r collections/requirements.yml
# ansible-galaxy role install -r roles/requirements.yml
# install azure collection requirements
# pip3 install -r ~/.ansible/collections/ansible_collections/azure/azcollection/requirements.txt
```

### Install the AWS SSM plugin
```
sudo dnf install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm
# on Ubuntu
# curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
# sudo dpkg -i session-manager-plugin.deb
```

### Install Azure CLI
```
#Install az cli on RHEL 9 https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=dnf
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo dnf install -y https://packages.microsoft.com/config/rhel/9.0/packages-microsoft-prod.rpm
sudo dnf install azure-cli
# Authenticate to Azure
az login
az account list --output table
az account set --subscription "00000000-0000-0000-0000-000000000000"
```

## Define environment variables
```
export AWS_ACCESS_KEY_ID=accesskeyid
export AWS_SECRET_ACCESS_KEY=secretaccesskey
```

## View AWS Inventory
```
ansible-inventory -i inventory.aws_ec2.yml --list --yaml
```

## View Azure Inventory
```
ansible-inventory -i inventory.azure_rm.yml --list --yaml
```

## Ping Linux Hosts to Check Connectivity
```
ansible -m ping -i inventory.aws_ec2.yml --limit='!_Windows' all
```

## Ping Windows Hosts to Check Connectivity
```
ansible -m win_ping -i inventory.aws_ec2.yml --limit='epic-kpr-sapph' all
```

## Provision Ansible host
```
ansible-playbook -i inventory.aws_ec2.yml --limit=ansible01* playbook-deploy-rhel-ansible-vm.yml
```

## Provision Storage
```
ansible-playbook -i inventory.aws_ec2.yml --limit=epic-msql-sapph playbook-provision-storage.yml
```

## Install SQL
```
ansible-playbook -i inventory.aws_ec2.yml --limit=epic-msql-sapph playbook-deploy-microsoft-sql.yml
```