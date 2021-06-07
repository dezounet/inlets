# [Inlets](https://github.com/inlets/inlets) packaging inside a docker image.

Inlets lets you... in! It uses a websocket to create a tunnel between a client
and a server. The server is typically a machine with a public IP address, and
the client is on a private network with no public address.

Supported architectures:

* amd64
* arm (raspberry pi 4)

## Tags

* latest (that's probably what you need: it will automatically pick amd64 or arm based on your current platform)
* arm
* amd64

## How to run the container

### ...on the server machine

```bash
docker run -p 80:80 dezsh/inlets server \
    --port 80 \
    --token <shared_token>
```

This will:

* Make the service hosted on the client available at port 80  
* Expect the client to connect to port 8080 to bring up the tunnel
* Set the token to authenticate a client

### ...on the client machine

```bash
docker run dezsh/inlets client \
    --url=ws://<inlets_server_ip>:80 \
    --upstream=http://<local_service_ip>:<local_service_port> \
    --token  <shared_token> \
    --insecure  # you shouldn't use this in production. I'd advise you
                # to use `wss` instead of `ws` in `--url` parameter
```

This will:

* Connect to the inlets server using the `url` argument. Port should match the one
  you configured on the server side (`port` parameter, here we used port `80`)
* Forward requests received from the server to `upstream` (thus making it
  avalaible to anyone being able to reach the inlets server)
* Tell the client which token to use to authenticate against the server

## Detailed documentation

* For the server side:

    ```bash
    docker run --rm -ti dezsh/inlets server --help

    Start the tunnel server on a machine with a publicly-accessible IPv4 IP
    address such as a VPS.

    Note: You can pass the --token argument followed by a token value to both the
    server and client to prevent unauthorized connections to the tunnel.

    Usage:
      inlets server [flags]

    Examples:
      # Bind the data and control plane to 80 and 8080
      inlets server --port 80 \
        --control-port 8080

      # Bind the control-plane to 127.0.0.1:
      inlets server --port 80 \
        --control-port 8001 \
        --control-addr 127.0.0.1

    Flags:
          --control-addr string          address tunnel clients should connect to (default "0.0.0.0")
      -c, --control-port int             control port for tunnel (default 8001)
          --data-addr string             address the server should serve tunneled services on (default "0.0.0.0")
          --disable-transport-wrapping   disable wrapping the transport that removes CORS headers for example
      -h, --help                         help for server
      -p, --port int                     port for server and for tunnel (default 8000)
          --print-token                  prints the token in server mode
      -t, --token string                 token for authentication
      -f, --token-from string            read the authentication token from a file
    ```

* For the client side:

    ```bash
    docker run --rm -ti dezsh/inlets client --help

    Start the tunnel client.

    Usage:
      inlets client [flags]

    Examples:
    # Start an insecure tunnel connection over your local network
      inlets client \
        --url=ws://192.168.0.101:80 \
        --upstream=http://127.0.0.1:3000 \
        --token TOKEN \
        --insecure

      # Start a secure tunnel connection over the internet to forward a Node.js
      # server running on port 3000
      inlets client \
        --url=wss://192.168.0.101 \
        --upstream=http://127.0.0.1:3000 \
        --token TOKEN

      Note: You can pass the --token argument followed by a token value to both the server and client to prevent unauthorized connections to the tunnel.

    Flags:
      -h, --help                help for client
          --insecure            allow the client to connect to a server without encryption
          --print-token         prints the token in server mode
          --strict-forwarding   forward only to the upstream URLs specified (default true)
      -t, --token string        authentication token
      -f, --token-from string   read the authentication token from a file
      -u, --upstream string     upstream server i.e. http://127.0.0.1:3000
      -r, --url string          server address i.e. ws://127.0.0.1:8000
    ```
