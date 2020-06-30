# Ansible for Galaxy servers for Masters project

## Installing Ansible roles

To install all the roles in `requirements.yml` do:

```bash
ansible-galaxy install -p roles -r requirements.yml
```
## Hashicorp vault

To get the vault token, ensure that vault is unsealed and on commander.sanbi.ac.za run:

```bash
VAULT_TOKEN=SuperSecretRootTokenInBitwarden VAULT_ADDR=https://commander.sanbi.ac.za:8200 vault token create -policy deploy
```

To use the Vault:

```bash
VAULT_TOKEN="blah" VAULT_ADDR="https://commander.sanbi.ac.za:8200" ansible-playbook -u ubuntu -i hosts galaxy.yml
```

The `-i` and `-u` might not be necessary if you have `inventory` and `remote_user` set in `ansible.cfg`.

# Terraform configuration

The Terraform configuration dir contains Hashicorp Terraform configuration for
creating the Galaxy server on the SANBI OpenStack cloud. Before using it, as much as
possible of the infrastructure should be imported to the Terraform state file
with `terraform import`. See the README in the Terraform directory for more info.
