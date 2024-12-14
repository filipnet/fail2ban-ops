# fail2ban-ops
<img src="images/logo.webp" alt="Logo" width="30%" align="right" hspace="30" vspace="20"/>
fail2ban-ops is a collection of scripts designed to assist with the management, monitoring, and automation of Fail2Ban. These tools allow system administrators to easily check the status of Fail2Ban jails, unban IP addresses, and analyze blocked IP statistics in a firewall environment. 

<!-- TOC -->

- [fail2ban-ops](#fail2ban-ops)
    - [Features](#features)
    - [Prerequisites](#prerequisites)
    - [Installation](#installation)
    - [Usage](#usage)
        - [fail2ban-ops-status.sh](#fail2ban-ops-statussh)
        - [fail2ban-ops-unban.sh](#fail2ban-ops-unbansh)
        - [fail2ban-ops-stats.sh](#fail2ban-ops-statssh)
    - [Contributing](#contributing)
    - [License](#license)

<!-- /TOC -->

## Features
- Check the status of Fail2Ban jails and banned IPs.
- Remove an IP address or DNS-resolved IPs from a Fail2Ban jail.
- Analyze and display blocked IP statistics from firewall logs.

## Prerequisites
- Bash
- Fail2Ban
- Firewall with firewalld (for stats script)

## Installation
Clone the repository to your local machine:

```bash
git clone https://github.com/filipnet/fail2ban-ops.git
cd fail2ban-ops
chmod +x fail2ban-ops-*
```

## Usage

### fail2ban-ops-status.sh
Checks the status of Fail2Ban jails and lists banned IP addresses.

```bash
./fail2ban-ops-status.sh
```

### fail2ban-ops-unban.sh
Removes an IP address (IPv4/IPv6) or DNS-resolved IPs from a Fail2Ban jail.

```bash
./fail2ban-ops-unban.sh <IP/Hostname> <Jail-Name>
```

Example: Prevent Locking Yourself Out with Dynamic PPPoE IPs

If you are using a dynamic IP address (e.g., assigned via PPPoE from your ISP), Fail2Ban may occasionally block your own IP due to false-positive detections. To prevent permanently locking yourself out of your server, you can use the fail2ban-ops-unban.sh script to periodically unban your IP. This works by targeting a dynamic DNS hostname that always resolves to your current public IP.

Cron Job Example (runs every 5 minutes):

```bash
*/5 * * * * /root/fail2ban-ops/fail2ban-ops-unban.sh your-hostname.dyndns.org portscan >/dev/null 2>&1
```
This ensures that your current IP, even when dynamically assigned, is regularly removed from the specified Fail2Ban jail (e.g., portscan), preventing accidental lockouts.

### fail2ban-ops-stats.sh
Analyzes and displays blocked IP statistics from firewall logs based on Fail2Ban activity.

```bash
./fail2ban-ops-stats.sh
```

## Contributing
Contributions are welcome! Feel free to submit a pull request or open an issue for any bugs or feature requests.

## License
fail2ban-ops and all individual scripts are under the BSD 3-Clause license unless explicitly noted otherwise. Please refer to the [LICENSE](LICENSE).
