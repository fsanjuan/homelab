# Role: docker

Installs Docker and adds the `build` user to the docker group.

## What it does

- Installs required apt dependencies
- Adds Docker's official GPG key and apt repository
- Installs `docker-ce`, `docker-ce-cli`, `containerd.io`, `docker-buildx-plugin`, and `docker-compose-plugin`
- Enables the Docker service so it starts automatically after a reboot
- Adds the `build` user to the `docker` group so Docker can be used without sudo

## Notes

- The `build` user must already exist on the server (see the project [prerequisites](../../README.md#prerequisites))
- After the first run, log out and back in on the server for the group membership to take effect
