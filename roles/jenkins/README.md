# Role: jenkins

Runs a Jenkins LTS server as a Docker container with an admin user pre-configured.

## What it does

- Creates `/opt/jenkins` to hold the compose file and init scripts
- Deploys a `docker-compose.yml` with Jenkins LTS
- Disables the Jenkins setup wizard
- Creates the `pellegrini` admin user via a Groovy init script
- Starts the Jenkins container with a persistent volume for all data
- Restarts Jenkins if the config or init scripts change

## Prerequisites

The `jenkins_admin_password` variable must be set in `group_vars/all/vault.yml` and encrypted with ansible-vault:

```bash
ansible-vault create group_vars/all/vault.yml
```

Content:
```yaml
jenkins_admin_password: your_password_here
```

Run the playbook with:
```bash
ansible-playbook site.yml --ask-become-pass --ask-vault-pass
```

## Accessing Jenkins

Once running, open `http://<server-meshnet-ip>:8080` and log in with `pellegrini` and your vaulted password.

## Ports

| Port  | Purpose             |
|-------|---------------------|
| 8080  | Web UI              |
| 50000 | Agent communication |
