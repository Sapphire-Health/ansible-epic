# Ansible Checklist

**Note**: Bullets marked with ⚠️ indicate information that must be provided by the customer.

## SQL (Multi-purpose and Cogito)
* Manually initialize ephemeral disk as T: using script in scripts/AWS_ephemeral_disk.ps1
* ⚠️ Ensure `sql_install_source_dir` is set correctly in host_vars. This affects SQL version (e.g. 2019, 2022) and licensing (e.g. Standard, Enterprise). This information must come from the customer.
* Review and replace all service accounts and admin groups in host_vars.
* Make sure ephemeral disks survive reboot (TEST)!
