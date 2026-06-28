# Server Deployment & Self-Hosting

Fossil has self-hosted since 2007. The canonical Fossil repository runs as a CGI script on a Linode, sharing a VM with SQLite and over a dozen other projects. Fossil can run on a $5/month VPS, a Raspberry Pi, or a shared hosting account with only CGI access.

## Activation Methods Overview

There are **five ways** to run a Fossil server:

| Method | Description | Best For |
|--------|-------------|----------|
| **CGI** | Web server runs Fossil as CGI script | Merging into existing websites, shared hosting |
| **Socket Listener** | inetd/xinetd/stunnel/launchd/systemd invokes `fossil http` per request | Lightweight setups, TLS termination |
| **Stand-alone HTTP** | `fossil server` runs its own HTTP server | Quick setup, development, small deployments |
| **SCGI** | `fossil server --scgi` speaks SCGI protocol | nginx integration, high performance |
| **SSH** | `ssh://` URLs for direct access | No server setup, personal use |

You can run multiple methods simultaneously for the same repository.

## Repository Prep (Before Serving)

1. **Change the default admin password** — New repos get a 10-digit random password, but the Setup user is all-powerful. Set a stronger password under Admin → Users.
2. **Run Security Audit** — Admin → Security-Audit to verify permissions.
3. **Consider "Take it private"** — Start locked down, then open up feature-by-feature.
4. **Upload the repo file** to your server.

## Standalone Server (`fossil server` / `fossil ui`)

Built-in HTTP server — no external web server needed.

```bash
# Serve a single repo on port 8080 (default)
fossil server repo.fossil

# Custom port
fossil server repo.fossil -P 8080

# Bind to specific IP
fossil server repo.fossil -P 192.168.1.10:8080

# Serve multiple repos from a directory
fossil server --repolist /path/to/repos

# Serve all repos from global config
fossil server /

# Launch with web browser (binds to 127.0.0.1, auto-login)
fossil ui repo.fossil

# Start on a specific page
fossil ui --page "timeline?y=ci" repo.fossil
```

### Server Options

- `-P|--port [IP:]PORT` — Listen on specific IP and port
- `--repolist` — If REPOSITORY is a directory, list repos at `/`
- `--localauth` — Auto-login for localhost connections
- `--localhost` — Bind to 127.0.0.1 only (always true for `ui`)
- `--baseurl URL` — Set base URL (useful behind reverse proxies)
- `--https` — Indicate HTTPS terminated at reverse proxy
- `--cert FILE` — TLS certificate (fullchain.pem) for HTTPS
- `--pkey FILE` — TLS private key
- `--acme` — Serve `.well-known/` for Let's Encrypt
- `--chroot DIR` — Run in chroot jail
- `--skin LABEL` — Override skin
- `--files GLOBLIST` — Serve static files matching glob patterns
- `--extroot DIR` — Document root for `/ext` extension mechanism
- `--errorlog FILE` — Log HTTP errors to file
- `--max-latency N` — Kill requests exceeding N seconds (Unix only)
- `--scgi` — Accept SCGI instead of HTTP
- `--create` — Create repository if it doesn't exist
- `--jsmode MODE` — JavaScript delivery: `inline`, `separate`, or `bundled`
- `--nocompress` — Disable HTTP compression
- `--notfound URL` — Custom 404 redirect
- `--ckout-alias NAME` — Alias `/doc/NAME/` to `/doc/ckout/`
- `--mainmenu FILE` — Override mainmenu configuration
- `--socket-name NAME` — Use Unix domain socket instead of TCP

### `fossil ui` vs `fossil server`

| Feature | `fossil ui` | `fossil server` |
|---------|-------------|-----------------|
| Auto-launch browser | Yes | No |
| Bind address | 127.0.0.1 only | 0.0.0.0 (all interfaces) |
| Auto-login | Yes (full admin) | No (unless `--localauth`) |
| Repolist | Yes (default) | Only with `--repolist` |
| SSL redirect | Disabled by default | Honors `redirect-to-https` |

## CGI Mode

Most web servers (Apache, lighttpd, althttpd, nginx+fcgiwrap) can run Fossil as CGI.

### Single Repository CGI Script

```bash
#!/usr/bin/fossil
repository: /home/fossil/repo.fossil
```

### Multiple Repositories CGI Script

```bash
#!/usr/bin/fossil
directory: /home/fossil/repos
notfound: https://example.com/404
repolist
```

### CGI Control Lines

- `repository: PATH` — Single repository to serve
- `directory: PATH` — Directory of `.fossil` files (multi-repo)
- `notfound: URL` — Redirect for missing repos/pages
- `repolist` — Show repo list at `/`
- `localauth` — Grant admin to localhost connections
- `nossl` — Signal no SSL available
- `nocompress` — Disable compression
- `skin: LABEL` — Override skin
- `files: GLOBLIST` — Static file patterns to serve
- `setenv: NAME VALUE` — Set environment variables
- `HOME: PATH` — Shorthand for `setenv: HOME PATH`
- `errorlog: FILE` — Error log path
- `timeout: SECONDS` — Request timeout (default 600)
- `extroot: DIR` — Extension document root
- `redirect: REPO URL` — Redirect rules
- `cgi-debug: FILE` — Debug output
- `https` — Force HTTPS mode (needed behind reverse proxy)

### CGI File Permissions

- Fossil binary must be readable/executable
- All directories leading to Fossil binary must be readable
- CGI script must be executable
- Repository file must be writable (for SQLite journal files)
- Directory containing repository must be writable
- Temp directory must exist and be writable (even in chroot)

### Apache + CGI

```apache
# Option 1: Direct CGI execution
ScriptAlias /fossil /var/www/fossil/cgi-bin/repo.cgi

# Option 2: Rewrite to CGI
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteRule ^(.*)$ /path/to/repo.cgi/$1 [L]

# Option 3: Directory of repos
RewriteEngine On
RewriteRule ^(.*)$ /path/to/fossil.cgi/$1 [L]
```

### Apache + Nginx Reverse Proxy

When Apache runs behind Nginx, Fossil needs `HTTPS=on` to generate correct links:

```nginx
# Nginx config
proxy_set_header X-Forwarded-Proto $scheme;
```

```apache
# Apache config
SetEnvIf X-Forwarded-Proto "https" HTTPS=on
```

### Nginx + CGI (via fcgiwrap)

```nginx
location / {
    fastcgi_pass unix:/var/run/fcgiwrap.socket;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME /path/to/repo.cgi;
}
```

## SCGI Mode

SCGI provides CGI-like simplicity without the performance overhead of spawning a new process per request.

### Fossil Side

```bash
fossil server repo.fossil --scgi -P 9000
```

### Nginx SCGI Config

```nginx
location / {
    include scgi_params;
    scgi_pass localhost:9000;
    scgi_param SCRIPT_NAME "/";
    scgi_param HTTPS "on";
}
```

**Important**: Nginx doesn't send `PATH_INFO` or `SCRIPT_NAME` via SCGI by default. You must add `SCRIPT_NAME`.

### Full Nginx + SCGI + TLS Example (Debian/Ubuntu)

```nginx
# /etc/nginx/sites-enabled/local/example.com
server {
    server_name .example.com "";
    include local/generic;
    include local/code;
    
    access_log /var/log/nginx/example.com-https-access.log;
    error_log /var/log/nginx/example.com-https-error.log;

    # Bypass Fossil for static content
    location /code/doc/html {
        root /var/www/example.com/code/doc/html;
        location ~* \.(html|ico|css|js|gif|jpg|png)$ {
            add_header Vary Accept-Encoding;
            access_log off;
            expires 7d;
        }
    }

    # Proxy to Fossil SCGI
    location /code {
        include local/code;
        
        # Extended caching for immutable URLs (hashed content)
        location ~ "/(artifact|doc|file|raw)/[0-9a-f]{40,64}" {
            add_header Cache-Control "public, max-age=31536000, immutable";
            include local/code;
            access_log off;
        }
        
        # Lesser caching for quasi-static content
        location ~* \.(css|gif|ico|js|jpg|png)$ {
            add_header Vary Accept-Encoding;
            include local/code;
            access_log off;
            expires 7d;
        }
    }
}

# /etc/nginx/local/code
include scgi_params;
scgi_pass 127.0.0.1:12345;
scgi_param SCRIPT_NAME "/code";

# /etc/nginx/local/generic
root /var/www/$host;
listen 80;
listen [::]:80;
charset utf-8;
```

### Nginx Proxying Fossil HTTP (Alternative to SCGI)

```nginx
location /code {
    rewrite ^/code(/.*) $1 break;
    proxy_pass http://127.0.0.1:12345;
}
```

### Allow Large Unversioned File Uploads

```nginx
location /code {
    client_max_body_size 20M;
    include local/code;
}
```

### fail2ban Integration

```bash
sudo apt install fail2ban  # ⚠️ Runs with root privileges — verify package source before installing

```ini
# /etc/fail2ban/filter.d/nginx-fossil-login.conf
[Definition]
failregex = ^<HOST> - .*POST .*/login HTTP/..." 401
```

```ini
# /etc/fail2ban/jail.local
[nginx-fossil-login]
enabled = true
logpath = /var/log/nginx/*-https-access.log
```

## Socket Listener (inetd/systemd/stunnel)

### inetd

```
# /etc/inetd.d/fossil
8080 stream tcp nowait nobody /usr/bin/fossil fossil http /path/to/repo.fossil
```

### systemd Socket Activation

```ini
# /etc/systemd/system/fossil.socket
[Socket]
ListenStream=8080

[Install]
WantedBy=sockets.target
```

```ini
# /etc/systemd/system/fossil@.service
[Service]
ExecStart=/usr/bin/fossil http /path/to/repo.fossil
StandardInput=socket
User=fossil
```

### stunnel (TLS Termination)

```ini
; /etc/stunnel/fossil.conf
[fossil]
accept = 443
connect = 8080
cert = /etc/stunnel/fossil.pem
```

## SSH Access

Fossil supports SSH for remote repository access without a running server.

```bash
# Clone via SSH
fossil clone ssh://user@host://path/to/repo.fossil repo.fossil

# Sync via SSH
fossil sync ssh://user@host//share/repo.fossil

# Push via SSH
fossil push ssh://user@host//share/repo.fossil

# Specify SSH command
fossil clone -c "ssh -i ~/.ssh/deploy_key" ssh://host//repo.fossil

# Specify Fossil path on remote
fossil clone ssh://host//repo.fossil?fossil=/home/user/bin/fossil
```

### SSH URL Formats

```
ssh://[user@]host[:port]/path/to/repo.fossil
ssh://[user@]host[:port]//absolute/path/to/repo.fossil
```

**Note**: SSH paths use `//` after the host for absolute paths.

### SSH PATH Issues

SSH daemon's PATH may differ from interactive shell PATH. If Fossil isn't found on remote:
1. Install Fossil where sshd expects it, OR
2. Use `?fossil=/absolute/path/to/fossil` in the URL

### SSH Setup

1. User must have shell access on the remote host
2. The `fossil` binary must be in the remote user's PATH
3. Use `--fossilcmd PATH` if Fossil is in a non-standard location
4. SSH keys recommended for passwordless access

## Reverse Proxy (nginx)

```nginx
server {
    listen 80;
    server_name fossil.example.com;
    
    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

With HTTPS termination at the proxy, add `--https` to the `fossil server` command so Fossil generates `https:` URLs.

## SSL/TLS

### Built-in TLS (v2.18+)

```bash
# Using certificate files
fossil server --cert /path/to/fullchain.pem --pkey /path/to/privkey.pem repo.fossil

# Using stored settings
fossil set ssl-cert /path/to/fullchain.pem
fossil set ssl-key /path/to/privkey.pem
fossil server repo.fossil
```

### Behind Reverse Proxy (Recommended)

Terminate SSL at the reverse proxy (nginx, Apache, Caddy) and use HTTP between proxy and Fossil.

### Let's Encrypt with Certbot (nginx)

```bash
sudo apt install certbot python3-certbot-nginx  # ⚠️ Runs with root privileges
sudo certbot --nginx -d fossil.example.com
```

### Let's Encrypt with ACME (Built-in)

```bash
# Serve .well-known for certificate validation
fossil server --acme repo.fossil
```

### Self-Signed Certificates

Fossil will prompt to accept self-signed certs on first connection. Verify the fingerprint, then answer "always".

### CA Certificate Issues

```bash
# Point to custom CA cert
fossil set --global ssl-ca-location /path/to/ca.pem

# FreeBSD: install ca_root_nss package
sudo pkg install ca_root_nss  # ⚠️ Runs with root privileges

# Windows: download cacert.pem and set
fossil set --global ssl-ca-location %userprofile%\cacert.pem
```

### Client-Side Certificates

```bash
# Concatenate private key + certificate into single file
fossil set ssl-identity /path/to/client.pem
# or
fossil clone --ssl-identity /path/to/client.pem https://host/repo
```

## TLS Force Redirect

```bash
fossil set redirect-to-https 1
```

This makes Fossil redirect HTTP to HTTPS when accessed via `fossil server`.

## CGI Server Extensions (`/ext`)

Fossil can serve CGI extensions from an "extroot" directory, allowing custom web apps integrated with Fossil's authentication.

### Setup

```bash
# In CGI script
extroot: /path/to/extensions

# Or via command line
fossil server --extroot /path/to/extensions repo.fossil
```

### URL Format

```
https://example.com/ext/extension-name
```

### How It Works

1. Fossil receives request for `/ext/something`
2. Looks for executable file at `$EXTROOT/something`
3. If executable, runs it as CGI
4. If readable but not executable, serves as static content

### Extension Environment Variables

Standard CGI variables plus Fossil-specific:

| Variable | Description |
|----------|-------------|
| `FOSSIL_USER` | Logged-in username (empty if not logged in) |
| `FOSSIL_CAPABILITIES` | User's capability letters |
| `FOSSIL_REPOSITORY` | Path to the repository file |
| `FOSSIL_URI` | Prefix of REQUEST_URI for the Fossil CGI |
| `FOSSIL_NONCE` | CSP nonce for inline scripts |

### Extension Development

```bash
# Quick preview while developing
fossil ui --extpage myapp.tcl
```

## Chiselapp Hosting

[Chiselapp](https://chiselapp.com) provides free Fossil repository hosting with full web UI access.

### Step-by-Step Setup

1. **Create account** — visit https://chiselapp.com and register
2. **Get project code** — run locally:
   ```bash
   fossil info -R myrepo.fossil
   ```
   Look for the "Project Code" UUID in the output.
3. **Create repository on Chiselapp** — fill in name, password, and project code
5. **Push your repository**:
   ```bash
   fossil push https://user:pass@chiselapp.com/user/<account>/repository/<project> -R myrepo.fossil --once
   ```
   Use `--once` for initial push only (no sync back).

   ⚠️ **Security**: Putting passwords in URLs exposes them in shell history, process lists, and error logs. Prefer:
   ```bash
   # Let Fossil prompt for password interactively
   fossil push https://user@chiselapp.com/user/<account>/repository/<project> -R myrepo.fossil --once
   ```

### Post-Push Fixes

- **Shun the initial empty check-in** that Chiselapp creates
- **Restore home page**: Admin → Configuration → set "Index Page"
- Fix doc links: change `/doc/trunk/...` to `/doc/tip/...`

### Keeping in Sync

```bash
# ⚠️ Avoid passwords in URLs — use interactive prompt instead:
fossil push https://user@chiselapp.com/user/<account>/repository/<project> -R myrepo.fossil
```
```

## Multi-Repo Server Setup

### Serve Directory of Repos

```bash
fossil server --repolist /path/to/repos
```

URL: `https://host/XYZ` serves `/path/to/repos/XYZ.fossil`

### CGI Multi-Repo

```bash
#!/usr/bin/fossil
directory: /home/fossil/repos
notfound: https://example.com/404
repolist
```

### Nginx Name-Based Virtual Hosting

```nginx
server {
    server_name project1.example.com;
    location / {
        include scgi_params;
        scgi_pass 127.0.0.1:9001;
        scgi_param SCRIPT_NAME "/";
    }
}

server {
    server_name project2.example.com;
    location / {
        include scgi_params;
        scgi_pass 127.0.0.1:9002;
        scgi_param SCRIPT_NAME "/";
    }
}
```

## Post-Activation Configuration

After the server is running:

1. **Add user accounts** — Use categories (Admin → Users) to define access policies
2. **Test access** — Verify each user category can access what they need
3. **Customize skin** — Admin → Skin
4. **Enable search** — Admin → Search (for embedded docs)
5. **Set up email alerts** — Admin → Notification
6. **Enable logging** — Check error logs, access logs
7. **Run Security Audit** — Admin → Security-Audit periodically

## Performance Considerations

- **CGI** spawns a new Fossil process per request — simple but inefficient for high traffic
- **SCGI** avoids process spawning overhead — best for nginx integration
- **Standalone** is efficient for small-to-medium deployments
- **Static content** can be served directly by nginx (bypass Fossil) for better performance
- **Immutable URLs** (containing hashes) can have aggressive caching headers
- **Fossil is lightweight** — runs fine on a $5/month VPS or Raspberry Pi
