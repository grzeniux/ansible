# Ansible USB Serial Management

Managing udev rules for USB serial devices on RPi hosts.

## 📁 Structure

```
ansible/
├── inventory/hosts.yml          # Host definitions (automotive, security)
├── group_vars/
│   ├── all.yml                  # Common settings
│   ├── automotive.yml           # USB rules for rpi (automotive)
│   └── security.yml             # USB rules for rpi4b (security)
├── roles/udev/                  # Role for managing udev rules
├── scripts/
│   └── list-usb-serial.sh       # Script for USB device scanning
├── scan-usb.yml                 # Playbook: scan USB devices on hosts
├── site.yml                     # Playbook: deploy udev rules
└── manage-runner.yml            # Playbook: monitor GitHub Actions Runner
```

---

## 🚀 Quick Start

### 1. Scan USB Devices (remotely via Ansible)

```bash
cd /mnt/c/Users/grzen/Documents/_Project/ansible

# Scan all hosts
ansible-playbook scan-usb.yml -i inventory/hosts.yml --ask-pass

# Only automotive group (rpi)
ansible-playbook scan-usb.yml -i inventory/hosts.yml --ask-pass -l automotive

# Only security group (rpi4b)
ansible-playbook scan-usb.yml -i inventory/hosts.yml --ask-pass -l security

# Specific host
ansible-playbook scan-usb.yml -i inventory/hosts.yml --ask-pass -l rpi
```

**What it does:**
- Copies script to hosts and runs it remotely
- Lists all `/dev/ttyUSB*` and `/dev/ttyACM*` devices on each host
- Shows Vendor ID, Product ID, Serial Number

**Example output:**
```
TASK [Display USB devices] *******************
ok: [rpi] => {
    "msg": [
        "📱 USB Serial Devices detected:",
        "════════════════════════════════",
        "",
        "Device: /dev/ttyUSB0",
        "  Manufacturer: Silicon Labs",
        "  Vendor ID:     10c4",
        "  Product ID:    ea60",
        "  Serial:        0001",
        "",
        "Device: /dev/ttyUSB1",
        "  Manufacturer: FTDI",
        "  Vendor ID:     0403",
        "  Product ID:    6001",
        "  Serial:        FTCLKGEO",
        "",
        "════════════════════════════════",
        "✅ Found 2 device(s)"
    ]
}
```

---

### 2. Edit Configuration
Add/update entries in `group_vars/automotive.yml` or `group_vars/security.yml`:
```yaml
usb_udev_rules:
  - comment: "CP2102 - ESP32 DevKit"
    serial: "0001"
    vendor: "10c4"
    product: "ea60"
    symlink: "ttyAUTO_ECU"
  
  - comment: "FTDI - Console"
    serial: "FTCLKGEO"
    vendor: "0403"
    product: "6001"
    symlink: "ttyAUTO_CONSOLE"
```

---

### 3. Deploy to Hosts

#### All hosts (rpi + rpi4b)
```bash
cd /mnt/c/Users/grzen/Documents/_Project/ansible
ansible-playbook site.yml -i inventory/hosts.yml --ask-pass --ask-become-pass
```

#### Only automotive group (rpi)
```bash
ansible-playbook site.yml -i inventory/hosts.yml --ask-pass --ask-become-pass -l automotive
```

#### Only security group (rpi4b)
```bash
ansible-playbook site.yml -i inventory/hosts.yml --ask-pass --ask-become-pass -l security
```

#### Specific host
```bash
# Only rpi
ansible-playbook site.yml -i inventory/hosts.yml --ask-pass --ask-become-pass -l rpi

# Only rpi4b
ansible-playbook site.yml -i inventory/hosts.yml --ask-pass --ask-become-pass -l rpi4b
```

---

## 🔍 Verify

### Test connectivity
```bash
# All hosts
ansible all -i inventory/hosts.yml -m ping --ask-pass

# Only automotive
ansible automotive -i inventory/hosts.yml -m ping --ask-pass

# Only security
ansible security -i inventory/hosts.yml -m ping --ask-pass
```

### Check deployed rules
```bash
# On rpi (automotive)
ansible rpi -i inventory/hosts.yml -a "cat /etc/udev/rules.d/99-usb-serial.rules" --ask-pass

# On rpi4b (security)
ansible rpi4b -i inventory/hosts.yml -a "cat /etc/udev/rules.d/99-usb-serial.rules" --ask-pass
```

### Check symlinks (after connecting devices)
```bash
# List all /dev/tty*
ansible all -i inventory/hosts.yml -m shell -a "ls -la /dev/tty*" --ask-pass

# Check specific symlink
ansible rpi -i inventory/hosts.yml -m shell -a "ls -la /dev/ttyESP32 /dev/ttyPICO" --ask-pass
```

---

## 🤖 GitHub Actions Runner - Monitoring

Playbook to verify GitHub Actions runner is running correctly after power restart.

### Check runner status

#### All hosts
```bash
ansible-playbook manage-runner.yml -i inventory/hosts.yml --ask-pass --ask-become-pass
```

#### Only automotive (rpi)
```bash
ansible-playbook manage-runner.yml -i inventory/hosts.yml --ask-pass --ask-become-pass -l automotive
```

#### Only security (rpi4b)
```bash
ansible-playbook manage-runner.yml -i inventory/hosts.yml --ask-pass --ask-become-pass -l security
```

**What it checks:**
- Whether `/opt/actions-runner` directory exists
- Status of systemd service `actions.runner.*.service`
- Whether runner process is active
- Service uptime
- Active GitHub Actions workflows

---

## 📝 Quick Commands

If SSH keys are configured (no need for `--ask-pass`):

```bash
# Deploy to all
ansible-playbook site.yml -i inventory/hosts.yml --ask-become-pass

# Deploy only to automotive
ansible-playbook site.yml -i inventory/hosts.yml --ask-become-pass -l automotive

# Ping test
ansible all -i inventory/hosts.yml -m ping --ask-pass
```

**Important:** Run playbooks from the main ansible folder for proper configuration loading.

---

## 🛠️ Troubleshooting

### Problem: "Ansible is being run in a world writable directory"
**Solution:** This is just a warning — ignore it or set `export ANSIBLE_CONFIG=/dev/null`

### Problem: "SSH password" doesn't work
**Solution:** Copy SSH keys:
```bash
ssh-keygen -t ed25519  # if you don't have a key
ssh-copy-id grzeniux@192.168.0.10
ssh-copy-id grzeniux2@192.168.0.20
```



---

## 📚 Hosts

| Host | IP | Group | User |
|------|----|----|------|
| rpi | 192.168.0.10 | automotive | grzeniux |
| rpi4b | 192.168.0.20 | security | grzeniux2 |

---

**Ready to go!** 🎯
