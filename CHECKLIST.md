# Ansible Checklist

## SQL
* Ensure `sql_install_source_dir` is set correctly in host_vars. This affects SQL version and licensing.
* Review and replace all service accounts and admin groups in host_vars.
* Make sure ephemeral disks survive reboot (TEST)!