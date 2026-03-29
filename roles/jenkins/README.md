# Role: jenkins

Runs a Jenkins LTS server as a Docker container with Docker Pipeline support for containerised builds.

## What it does

- Builds a custom Jenkins image with the Docker CLI and `docker-workflow` plugin pre-installed
- Mounts the host Docker socket so Jenkins can spin up build agent containers
- Adds Jenkins to the host Docker group so socket access works without root
- Disables the Jenkins setup wizard
- Creates the `pellegrini` admin user via a Groovy init script
- Starts Jenkins behind Traefik at `/jenkins`
- Restarts Jenkins if the config or init scripts change

## Docker Pipeline

Pipelines declare their own build environment using public Docker Hub images:

```groovy
pipeline {
    agent { docker { image 'node:20' } }
    stages {
        stage('Build') {
            steps {
                sh 'npm install && npm run build'
            }
        }
    }
}
```

Jenkins pulls the image on first use and spins up a container for each build. No agent configuration needed in Jenkins UI.

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

Once running, open `https://<your-meshnet-hostname>/jenkins` and log in with `pellegrini` and your vaulted password.

## Ports

| Port  | Purpose             |
|-------|---------------------|
| 50000 | Agent communication |
