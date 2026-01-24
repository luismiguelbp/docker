# Node-RED

https://nodered.org

Low-code programming for event-driven applications.

[Source code repository](https://github.com/node-red/node-red)

## Links

See the following links for more information on Node-RED:

- Documentation: <https://nodered.org/docs/>
- User guide: <https://nodered.org/docs/user-guide/>
- GitHub: <https://github.com/node-red/node-red>

## Useful commands

```shell
docker exec -it <container> node-red-admin --help
docker exec -it <container> node-red-admin list
```

## Admin password setup

To password protect the Node-RED editor and admin API, add an `adminAuth` block
to your `${DOCKER_PATH}/data/node-red/settings.js` file.

See <https://nodered.org/docs/security.html> for details.

1. Generate a password hash:

```shell
docker exec -it <container> node-red-admin hash-pw
```

2. Add the `adminAuth` block to `settings.js`:

```javascript
adminAuth: {
    type: "credentials",
    users: [{
        username: "admin",
        password: "",
        permissions: "*"
    }]
},
```

Replace the `password` value with the hash you generated.

3. Restart Node-RED:

```shell
docker compose restart node-red
```
