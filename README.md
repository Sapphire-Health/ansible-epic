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
ansible-galaxy collection install amazon.aws community.aws ansible.utils community.windows ansible.windows ansible.posix community.general microsoft.ad community.crypto prometheus.prometheus trippsc2.cis
# deactivate
```

## Activate venv and Install Deps (Azure)
```
source ~/venv/azure/bin/activate
# set vscode ansible.python.activationScript to ~/venv/azure/bin/activate
pip3 install ansible-lint pypsrp pywinrm requests[socks]
ansible-galaxy collection install azure.azcollection community.aws ansible.utils community.windows ansible.windows ansible.posix community.general microsoft.ad community.crypto prometheus.prometheus trippsc2.cis
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
git clone https://github.com/Sapphire-Health/ansible-role-smtp.git ./roles/smtp
git clone https://github.com/Sapphire-Health/ansible-role-prometheus.git ./roles/prometheus
git clone https://github.com/Sapphire-Health/ansible-role-certificate-authority.git ./roles/certificate_authority
git clone https://github.com/Sapphire-Health/ansible-role-windows-exporter.git ./roles/windows_exporter
git clone https://github.com/Sapphire-Health/ansible-role-linux-exporter.git ./roles/linux_exporter
git clone https://github.com/Sapphire-Health/ansible-role-iris.git ./roles/iris
git clone https://github.com/Sapphire-Health/ansible-role-domain-join.git ./roles/domain_join
git clone https://github.com/Sapphire-Health/ansible-role-subscription-manager.git ./roles/subscription_manager
git clone https://github.com/Sapphire-Health/ansible-role-cogito.git ./roles/cogito
ansible-galaxy role install linux-system-roles.storage
# for prod
ansible-galaxy role install -r roles/requirements.yml --force
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
ansible -m win_ping -i inventory.aws_ec2.yml --limit='_Windows' all
```

## Provision Ansible host
```
ansible-playbook -i inventory.aws_ec2.yml --limit=ansible01* playbook-deploy-rhel-ansible-vm.yml
# provision ansible users
ansible-playbook -i inventory.aws_ec2.yml --limit=ansible01.sapphire.dev -e "ansible_connection=local" playbook-provision-ansible-ssh-users.yml --become
```

## AD Provisioning
```
# set up users and groups
ansible-playbook -i inventory.aws_ec2.yml --limit=epic-msql-sapph playbook-provision-ad.yml
# remove computer from AD
ansible-playbook -i inventory.aws_ec2.yml --limit=epic-kpr-sapph -e computer=epic-msql-sapph playbook-remove-computer-ad.yml
```

## Provision Storage
```
ansible-playbook -i inventory.aws_ec2.yml --limit=tstodb.sapphire.dev playbook-provision-storage.yml
# ansible-playbook -i inventory.azure_rm.yml --limit=has_managed_disks playbook-provision-storage.yml
ansible-playbook -i inventory.azure_rm.yml --limit=clarity playbook-provision-storage.yml
```

## Install SQL
```
ansible-playbook -i inventory.aws_ec2.yml --limit=epic-msql-sapph playbook-deploy-microsoft-sql.yml
```

## Install Kuiper
```
ansible-playbook -i inventory.aws_ec2.yml --limit=epic-kpr-sapph1 playbook-deploy-kuiper.yml
ansible-playbook -i inventory.aws_ec2.yml --limit=epic-kpr-sapph2 playbook-deploy-kuiper.yml
```

## Install System Pulse
```
ansible-playbook -i inventory.aws_ec2.yml --limit=epic-sp-sapph playbook-deploy-system-pulse.yml
```

## Install SMTP Forwarder
```
ansible-playbook -i inventory.aws_ec2.yml --limit=epic-smtp-sapph playbook-deploy-smtp.yml
```

## Add domain user to local admins
```
ansible-playbook -i inventory.aws_ec2.yml --limit='*hsw*' playbook-add-local-admins.yml
```

## Deploy Prometheus
```
ansible-playbook -i inventory.aws_ec2.yml --limit=ansible01 playbook-deploy-prometheus.yml --become
```

## Deploy Prometheus windows_exporter
```
ansible-playbook -i inventory.aws_ec2.yml --limit=_Windows playbook-deploy-windows_exporter.yml
```

## Deploy Prometheus node_exporter
```
ansible-playbook -i inventory.aws_ec2.yml --limit=tstodb playbook-deploy-node_exporter.yml --become
```

## Deploy Iris
1. Define storage, user, domain_join and Iris variables for Iris hosts (domain_groups, sssd_template, etc)
2. Update the SSH and SSSD templates
```
ansible-playbook -i inventory.aws_ec2.yml --limit=tstodb playbook-deploy-iris.yml --become
dev command
ansible-playbook -i inventory.yml --limit=tstodb.sapphire.dev playbook-deploy-iris.yml --become -e @extra_vars/users.yml
```

## Apply CIS remediations to Windows machines
```
ansible-playbook -i inventory.aws_ec2.yml --limit=_Windows playbook-apply-windows-server-2022-cis-hardening.yml
```

## Delete VM and attached disks WARNING: INTENDED FOR ITERATIVE DEVELOPMENT TESTING, USE WITH CAUTION
```
ansible-playbook -i inventory.aws_ec2.yml --limit=epic-msql-sapph playbook-delete-aws-instance-and-disks.yml
```

## Configure Linux Search Suffix
ansible-playbook -i inventory.aws_ec2.yml --limit='tstodb.sapphire.dev' playbook-configure-linux-search-suffix.yml

## Linux Create Local Users and Groups
ansible-playbook -i inventory.aws_ec2.yml --limit=tstodb.sapphire.dev playbook-deploy-iris.yml --become -e @extra_vars/users.yml --tags users,groups

## Linux Join Domain
ansible-playbook -i inventory.aws_ec2.yml --limit='tstodb.sapphire.dev' playbook-linux-join-domain.yml

## Logoff disconnected Windows sessions
```
ansible-playbook -i inventory.azure_rm.yml --limit '_Windows' playbook-logoff-disconnected-sessions.yml
```

## Populate known_hosts on all targeted Linux machines
```
ansible-playbook -i inventory.aws_ec2.yml --limit='*odb.sapphire.dev' playbook-linux-populate-known_hosts.yml
```

## SSH into Linux Host
```
ssh azureuser@10.3.2.69 -o ProxyCommand="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p -q azureuser@20.114.208.150"
# create tunnel
ssh -D 12345 azureuser@20.114.208.150
ssh -D 12346 lyasspiehler@34.208.130.180
ssh ec2-user@10.248.13.10 -i ~/.ssh/id_rsa_provision
```

# VSCode Tunnel Notes
```
https://code.visualstudio.com/docs/setup/linux#_install-vs-code-on-linux
https://dev.to/dorinandreidragan/work-from-anywhere-with-vscode-remote-tunnels-4o5i
https://learn.microsoft.com/en-us/azure/developer/dev-tunnels/security
apt install code
or
curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64' --output vscode_cli.tar.gz
tar -xf vscode_cli.tar.gz
cp code /usr/share/bin/

code tunnel user login --provider microsoft
code tunnel
or
code tunnel service install
```

# activate venv
# authenticate aws
# define env vars
ansible-playbook -i inventory.aws_ec2.yml --limit='tstodb*' playbook-provision-storage.yml
# ansible-playbook -i inventory.aws_ec2.yml --limit='*odb.sapphire.dev' playbook-linux-populate-known_hosts.yml
ansible-playbook -i inventory.aws_ec2.yml --limit='*odb.sapphire.dev' playbook-configure-linux-search-suffix.yml
ansible-playbook -i inventory.aws_ec2.yml --limit='*odb.sapphire.dev' playbook-linux-join-domain.yml
ansible-playbook -i inventory.aws_ec2.yml --limit='tstodb.sapphire.dev' playbook-deploy-iris.yml --become -e @extra_vars/users.yml
ansible-playbook -i inventory.aws_ec2.yml --limit='*odb.sapphire.dev' playbook-deploy-iris.yml --become -e @extra_vars/users.yml --skip-tags iris
instaserver.sh --variable_build