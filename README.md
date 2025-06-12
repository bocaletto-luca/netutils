# NetUtils — Networking Utility Toolkit for Linux

A professional Bash toolkit for everyday network tasks: downloads, uploads, port scans, latency and throughput tests.  
All output (stdout & stderr) is logged to `netutils.log`.

**Repository:**  
https://github.com/bocaletto-luca/netutils

---

## 🚀 Features

- **Download** files via `curl` or `wget`, with resume support  
- **Upload** files via `scp`, `rsync` or raw `nc` streams  
- **Port & Service Scan** with `nmap`  
- **Latency Test** using `ping`  
- **Throughput Test** using `iperf3`  
- Built-in **logging**, **error handling**, **help messages**  
- Dependency checks at startup  

---

## 📋 Prerequisites

Make sure the following tools are installed on your Linux system:

```bash`
bash curl wget nmap ping iperf3 scp rsync nc tee

Install on Debian/Ubuntu:

    sudo apt update && sudo apt install -y \
 
    curl wget nmap iperf3 openssh-client rsync netcat-openbsd

Installation

    Clone the repo:

    git clone https://github.com/bocaletto-luca/netutils.git

    cd netutils

Make the script executable:

    chmod +x netutils.sh

Usage:
     
    ./netutils.sh <command> [options]

Commands:    

    Run ./netutils.sh <command> --help for details on each command.
    
Examples
1. Download a File

Resume support with --resume:

    ./netutils.sh download \
    --url https://example.com/large.iso \
    --out large.iso \
    --resume
    
2. Upload a File

Via scp

     ./netutils.sh upload \
     --proto scp \
    --source ./backup.tar.gz \
    --dest /data/backup.tar.gz \
    --host server.example.com \
    --port 2222 \
    --user deploy

Via rsync

    ./netutils.sh upload \
    --proto rsync \
    --source ./website/ \
    --dest /var/www/html/ \
    --host web01.example.com \
    --port 2200 \
    --user www-data

Via nc

On the server side, run:

    nc -l -p 9001 > received.file

On your local machine:

    ./netutils.sh upload \
    --proto nc \
    --source ./large.bin \
    --host 192.168.1.50 \
    --port 9001

3. Port & Service Scan

Scan ports 1–2000 with SYN scan and save to scan.txt:

    ./netutils.sh scan \
    --target 192.168.1.10 \
    --ports 1-2000 \
    --type "-sS" \
    --output scan.txt

4. Latency Test (Ping)

Ping Google DNS 10 times at 0.5s intervals:

    ./netutils.sh pingtest \
    --target 8.8.8.8 \
    --count 10 \
    --interval 0.5

5. Throughput Test (iperf3)

Run an iperf3 throughput test for 30s:

    ./netutils.sh throughput \
    --host iperf.example.com \
    --port 5202 \
    --duration 30

Logging

All operations are logged to netutils.log in the script directory:

    tail -f netutils.log

