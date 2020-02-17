# Ansible for Galaxy servers for Masters project

To get the vault token, on commander.sanbi.ac.za run:

```bash
VAULT_TOKEN=SuperSecretKeyInBitwarden VAULT_ADDR=https://commander.sanbi.ac.za:8200 vault token create -policy deploy
```

To use the Vault:

```bash
VAULT_TOKEN="blah" VAULT_ADDR="https://commander.sanbi.ac.za:8200" ansible-playbook -u ubuntu -i hosts galaxy.yml
```

The `-i` and `-u` might not be necessary if you have `inventory` and `remote_user` set in `ansible.cfg`.
