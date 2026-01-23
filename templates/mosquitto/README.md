# Eclipse Mosquitto

Mosquitto is an open source implementation of a server for version 5.0, 3.1.1,
and 3.1 of the MQTT protocol. It also includes a C and C++ client library, and
the `mosquitto_pub` and `mosquitto_sub` utilities for publishing and
subscribing.

[Source code repository](https://github.com/eclipse/mosquitto)

[mosquitto.conf](https://github.com/eclipse/mosquitto/blob/master/mosquitto.conf)

## Links

See the following links for more information on MQTT:

- Community page: <http://mqtt.org/>
- MQTT specification: <https://docs.oasis-open.org/mqtt/mqtt/v5.0/mqtt-v5.0.html>

See the following links for more information on Mosquitto:

- Main homepage: <https://mosquitto.org/>
- Documentation: <https://mosquitto.org/documentation/>

## Useful commands

### Generating Passwords File

Use the `mosquitto_passwd` tool inside the running container:

```shell
# Create a new passwords file (use -c to create, omit -c to add users)
# Interactive mode - prompts for password
docker exec -it <container_name> mosquitto_passwd -c /mosquitto/config/passwords_file <username>

# Batch mode - password provided on command line (non-interactive)
docker exec -it <container_name> mosquitto_passwd -b -c /mosquitto/config/passwords_file <username> <password>

# Add additional users to an existing file (interactive)
docker exec -it <container_name> mosquitto_passwd /mosquitto/config/passwords_file <username>

# Add additional users to an existing file (batch mode)
docker exec -it <container_name> mosquitto_passwd -b /mosquitto/config/passwords_file <username> <password>
```

**Notes:**
- The `-c` flag creates a new file (removes existing users). Omit it to add users to an existing file.
- The `-b` flag enables batch mode, allowing the password to be provided on the command line instead of being prompted interactively.
- **Security Warning:** Using `-b` mode exposes the password in command history. Use interactive mode for production environments.
