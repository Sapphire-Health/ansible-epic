# Ansible Azure Inventory

## Requirements
* Set up dynamic inventory for Azure/AWS
    * An account with inventory access to Azure/AWS

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
pip3 install botocore boto3 ansible-lint pypsrp pywinrm requests[socks]
ansible-galaxy collection install amazon.aws community.aws ansible.utils community.windows ansible.windows ansible.posix community.general microsoft.ad
# deactivate
```

## Activate venv and Install Deps (Azure)
```
source ~/venv/azure/bin/activate
# set vscode ansible.python.activationScript to ~/venv/azure/bin/activate
pip3 install ansible-lint pypsrp pywinrm requests[socks]
ansible-galaxy collection install azure.azcollection community.aws ansible.utils community.windows ansible.windows ansible.posix community.general microsoft.ad
pip3 install -r ~/.ansible/collections/ansible_collections/azure/azcollection/requirements.txt
# deactivate
```

### Install Ansible Roles
```
# for dev
git clone https://github.com/Sapphire-Health/ansible-role-aws-linux-storage.git ./roles/aws_linux_storage
git clone https://github.com/Sapphire-Health/ansible-role-azure-linux-storage.git ./roles/azure_linux_storage
git clone https://github.com/Sapphire-Health/ansible-role-azure-windows-storage.git ./roles/azure_windows_storage
git clone https://github.com/Sapphire-Health/ansible-role-aws-windows-storage.git ./roles/aws_windows_storage
git clone https://github.com/Sapphire-Health/ansible-role-microsoft-sql.git ./roles/microsoft_sql
git clone https://github.com/Sapphire-Health/ansible-role-kuiper.git ./roles/kuiper
git clone https://github.com/Sapphire-Health/ansible-role-system-pulse.git ./roles/system_pulse
git clone https://github.com/Sapphire-Health/ansible-role-prometheus.git ./roles/prometheus
ansible-galaxy role install linux-system-roles.storage
# for prod
ansible-galaxy role install -r roles/requirements.yml
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
ansible -m win_ping -i inventory.aws_ec2.yml --limit='epic-msql-sapph' all
```

## Provision Ansible host
```
ansible-playbook -i inventory.aws_ec2.yml --limit=ansible01* playbook-deploy-rhel-ansible-vm.yml
```

## AD Provisioning
```
# set up users and groups
ansible-playbook -i inventory.aws_ec2.yml --limit=epic-msql-sapph playbook-provision-ad.yml
# remove computer from AD
ansible-playbook -i inventory.aws_ec2.yml --limit=epic-msql-sapph -e computer=epic-msql-sapph playbook-remove-computer-ad.yml
```

## Provision Storage
```
ansible-playbook -i inventory.aws_ec2.yml --limit=epic-msql-sapph playbook-provision-storage.yml
# ansible-playbook -i inventory.azure_rm.yml --limit=has_managed_disks playbook-provision-storage.yml
ansible-playbook -i inventory.azure_rm.yml --limit=clarity playbook-provision-storage.yml
```

## Install SQL
```
ansible-playbook -i inventory.aws_ec2.yml --limit=epic-msql-sapph playbook-deploy-microsoft-sql.yml
```

## Install Kuiper
```
ansible-playbook -i inventory.aws_ec2.yml --limit=epic-kpr-sapph playbook-deploy-kuiper.yml
```

## Install System Pulse
```
ansible-playbook -i inventory.aws_ec2.yml --limit=epic-sp-sapph playbook-deploy-system-pulse.yml
```

## Add domain user to local admins
```
ansible-playbook -i inventory.aws_ec2.yml --limit='*hsw*' playbook-add-local-admins.ym
```

## Deploy Prometheus
```
ansible-playbook -i inventory.azure_rm.yml --limit=prometheus playbook-deploy-prometheus.yml --become
```

## SSH into Linux Host
```
ssh azureuser@10.3.2.69 -o ProxyCommand="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p -q azureuser@20.114.208.150"
# create tunnel
ssh -D 12345 azureuser@20.114.208.150
```
