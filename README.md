# NetUtils — Networking Utility Toolkit for Linux
#### Author: Bocaletto Luca

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

```bash
bash curl wget nmap ping iperf3 scp rsync nc tee
```

Install on Debian/Ubuntu:

```bash
sudo apt update && sudo apt install -y \
  curl wget nmap iperf3 openssh-client rsync netcat-openbsd
```

---

## ⚙️ Installation

1. Clone the repo:  
   ```bash
   git clone https://github.com/bocaletto-luca/netutils.git
   cd netutils
   ```
2. Make the script executable:  
   ```bash
   chmod +x netutils.sh
   ```

---

## 📖 Usage

```bash
./netutils.sh <command> [options]
```

### Commands

| Command     | Description                                           |
|-------------|-------------------------------------------------------|
| `download`  | Download a file (curl|wget)                           |
| `upload`    | Upload a file (scp|rsync|nc)                          |
| `scan`      | Port/service scan (nmap)                              |
| `pingtest`  | Latency test (ping)                                   |
| `throughput`| Throughput test (iperf3)                              |

Run `./netutils.sh <command> --help` for details on each command.

---

## 🔧 Examples

### 1. Download a File

Resume support with `--resume`:

```bash
./netutils.sh download \
  --url https://example.com/large.iso \
  --out large.iso \
  --resume
```

### 2. Upload a File

#### Via `scp`

```bash
./netutils.sh upload \
  --proto scp \
  --source ./backup.tar.gz \
  --dest /data/backup.tar.gz \
  --host server.example.com \
  --port 2222 \
  --user deploy
```

#### Via `rsync`

```bash
./netutils.sh upload \
  --proto rsync \
  --source ./website/ \
  --dest /var/www/html/ \
  --host web01.example.com \
  --port 2200 \
  --user www-data
```

#### Via `nc`

On the **server** side, run:

```bash
nc -l -p 9001 > received.file
```

On your **local** machine:

```bash
./netutils.sh upload \
  --proto nc \
  --source ./large.bin \
  --host 192.168.1.50 \
  --port 9001
```

### 3. Port & Service Scan

Scan ports **1–2000** with SYN scan and save to `scan.txt`:

```bash
./netutils.sh scan \
  --target 192.168.1.10 \
  --ports 1-2000 \
  --type "-sS" \
  --output scan.txt
```

### 4. Latency Test (Ping)

Ping Google DNS **10** times at **0.5s** intervals:

```bash
./netutils.sh pingtest \
  --target 8.8.8.8 \
  --count 10 \
  --interval 0.5
```

### 5. Throughput Test (iperf3)

Run an iperf3 throughput test for **30s**:

```bash
./netutils.sh throughput \
  --host iperf.example.com \
  --port 5202 \
  --duration 30
```

---

## 📜 Logging

All operations are logged to `netutils.log` in the script directory:

```bash
tail -f netutils.log
```

---

## 🤝 Contributing

1. Fork the repo  
2. Create your feature branch:  
   ```bash
   git checkout -b feature/your-feature
   ```
3. Commit your changes:  
   ```bash
   git commit -m "Add new feature"
   ```
4. Push to the branch:  
   ```bash
   git push origin feature/your-feature
   ```
5. Open a Pull Request  

Please run `shellcheck netutils.sh` before submitting.

---

## 📄 License

This project is licensed under the MIT License © 2025  
[bocaletto-luca](https://github.com/bocaletto-luca)
