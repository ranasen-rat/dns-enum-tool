# 🔥 Advanced DNS Enumeration Tool

A powerful, colorful bash script for comprehensive DNS reconnaissance with beautiful HTML report generation.

![Bash](https://img.shields.io/badge/language-bash-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## 📋 Description

This advanced DNS enumeration tool performs comprehensive DNS reconnaissance on target domains. It queries multiple record types, performs zone transfer attempts, validates DNSSEC, and generates a stunning HTML report with all findings. Perfect for security researchers, system administrators, and penetration testers.

## ✨ Features

- **Complete DNS Record Enumeration**
  - A Records (IPv4 addresses)
  - AAAA Records (IPv6 addresses)
  - CNAME Records (Canonical names)
  - MX Records (Mail servers)
  - NS Records (Name servers)
  - TXT Records (Text records)
  - SRV Records (Service records)
  - PTR Records (Reverse DNS)
  - SOA Records (Start of Authority)

- **Advanced Capabilities**
  - 🔄 Zone Transfer Attempts
  - 🔐 DNSSEC Validation
  - 📊 Real-time progress bars
  - 🎨 Color-coded terminal output
  - 📱 Responsive HTML report generation

- **Beautiful HTML Report**
  - Modern gradient design
  - Interactive cards with hover effects
  - Color-coded record types
  - Mobile-responsive layout
  - Summary dashboard with counters

## 🚀 Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/dns-enum-tool.git

# Navigate to directory
cd dns-enum-tool

# Make the script executable
chmod +x dns_enum.sh
```

## 📖 Usage

```bash
./dns_enum.sh <domain>
```

### Example

```bash
./dns_enum.sh example.com
```

## 📊 Output

The script provides two types of output:

1. **Terminal Output**: Real-time, color-coded results with progress bars
2. **HTML Report**: `dns_enum_<domain>.html` - A beautiful, interactive report

### Sample Terminal Output
```
╔══════════════════════════════════════════════════════╗
║ 🔥 ADVANCED DNS ENUMERATION TOOL ║
╚══════════════════════════════════════════════════════╝
Target: example.com

🔍 A Records...
┌─ Progress ──────────────────────────────────────────────┐
│ [################################################## ] 100% │
└──────────────────────────────────────────────────────┘
  A → 93.184.216.34

📊 ENUMERATION SUMMARY
══════════════════════════════════════════════════════════
A:  1 | AAAA:  1 | CNAME:  0 | MX:  2
NS:  4 | TXT:  2 | SRV:  0 | PTR:  1
SOA:  1 | ZONE: ❌ | DNSSEC: ❌
```

## 🛠️ Requirements

- **Bash** 4.0 or higher
- **dig** (DNS lookup utility)
- **host** (DNS lookup utility)

### Installing Requirements

**Debian/Ubuntu/Kali:**
```bash
sudo apt-get update
sudo apt-get install dnsutils bind9-host
```

**RHEL/CentOS/Fedora:**
```bash
sudo yum install bind-utils
```

**Arch Linux:**
```bash
sudo pacman -S dnsutils
```

## 📁 Script Structure

```
dns_enum.sh
├── Progress Bar Function
├── Record Collection Functions
│   ├── A Records
│   ├── AAAA Records
│   ├── CNAME Records
│   ├── MX Records
│   ├── NS Records
│   ├── TXT Records
│   ├── SRV Records
│   ├── PTR Records
│   └── SOA Records
├── Advanced Features
│   ├── Zone Transfer
│   └── DNSSEC Validation
└── HTML Report Generator
```

## 🎨 HTML Report Preview

The generated HTML report features:

- **Gradient Header** with target domain
- **Summary Cards** showing counts for each record type
- **Detailed Tables** for each DNS record category
- **Color Coding** for easy visual scanning
- **Responsive Design** that works on mobile devices
- **Hover Effects** for interactive experience

## 🔍 What It Checks

| Record Type | Purpose | Example |
|------------|---------|---------|
| **A** | IPv4 addresses | 192.0.2.1 |
| **AAAA** | IPv6 addresses | 2001:db8::1 |
| **CNAME** | Canonical names | www → example.com |
| **MX** | Mail servers | mail.example.com |
| **NS** | Name servers | ns1.example.com |
| **TXT** | Text records | SPF, DKIM, etc. |
| **SRV** | Service records | _sip._tcp.example.com |
| **PTR** | Reverse DNS | 1.2.3.4 → hostname |
| **SOA** | Authority info | Primary NS, admin email |

## ⚠️ Important Notes

- Zone transfers are often disabled on production DNS servers
- Some domains may have rate limiting enabled
- DNSSEC validation requires the domain to be signed
- The tool respects DNS response times and timeouts

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⭐ Show Your Support

If you find this tool useful, please consider giving it a star on GitHub! It helps others discover the project.

## 🙏 Acknowledgments

- The dig utility developers
- DNS protocol designers
- Open source community
- All contributors and users

## 🚦 History
  - Added HTML report generation
  - Improved progress bars
  - Enhanced error handling
  - Added more SRV records
  - Initial release
  - Basic DNS enumeration
  - Terminal output only

---

**Disclaimer**: This tool is for educational and authorized testing purposes only. Always ensure you have permission to scan the target domain.
