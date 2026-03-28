# Role: jenkins

Runs a Jenkins LTS server as a Docker container.

## What it does

- Creates `/opt/jenkins` to hold the compose file
- Deploys a `docker-compose.yml` with Jenkins LTS
- Starts the Jenkins container with a persistent volume for all data

## Accessing Jenkins

Once running, open `http://<server-meshnet-ip>:8080` in your browser.

On first boot Jenkins will ask for an unlock key. Retrieve it with:

```bash
docker exec jenkins-jenkins-1 cat /var/jenkins_home/secrets/initialAdminPassword
```

## Ports

| Port  | Purpose              |
|-------|----------------------|
| 8080  | Web UI               |
| 50000 | Agent communication  |
