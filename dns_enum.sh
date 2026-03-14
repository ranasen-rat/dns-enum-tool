#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Progress bar function
progress_bar() {
    local duration=${1}
    local title="${2:-Progress}"
    local bar_length=50
    local elapsed=0

    echo -e "${CYAN}┌─ ${title} ──────────────────────────────────────────────┐${NC}"
    while [ $elapsed -le $duration ]; do
        local percentage=$((elapsed * 100 / duration))
        local filled_length=$((bar_length * elapsed / duration))
        local bar=$(printf "#%.0s" $(seq 1 $filled_length))
        local spaces=$(printf " %.0s" $(seq 1 $((bar_length - filled_length))))
        
        printf "\r│ [%-${bar_length}s] %3d%% │" "${bar}${spaces}" $percentage
        sleep 0.1
        elapsed=$((elapsed + 1))
    done
    echo -e "\n└──────────────────────────────────────────────────────┘${NC}"
}

if [ $# -eq 0 ]; then
    echo -e "${RED}Usage: $0 <domain>${NC}"
    exit 1
fi

DOMAIN="$1"
OUTPUT_FILE="dns_enum_${DOMAIN}.html"

echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC} ${CYAN}🔥 ADVANCED DNS ENUMERATION TOOL v2.0${NC} ${GREEN}║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${NC}"
echo -e "${YELLOW}Target: ${CYAN}${DOMAIN}${NC}\n"

# Initialize counters
A_COUNT=0
AAAA_COUNT=0
CNAME_COUNT=0
MX_COUNT=0
NS_COUNT=0
TXT_COUNT=0
SRV_COUNT=0
PTR_COUNT=0
SOA_COUNT=0
ZONE_TRANSFER_SUCCESS=0
DNSSEC_VALID=0

# Initialize arrays
A_RESULTS=()
AAAA_RESULTS=()
CNAME_RESULTS=()
MX_RESULTS=()
NS_RESULTS=()
TXT_RESULTS=()
SRV_RESULTS=()
PTR_RESULTS=()
SOA_RESULTS=()
ZONE_TRANSFER_RESULTS=()

add_record() {
    local type="$1"
    local result="$2"
    case $type in
        "A") ((A_COUNT++)); A_RESULTS+=("$result");;
        "AAAA") ((AAAA_COUNT++)); AAAA_RESULTS+=("$result");;
        "CNAME") ((CNAME_COUNT++)); CNAME_RESULTS+=("$result");;
        "MX") ((MX_COUNT++)); MX_RESULTS+=("$result");;
        "NS") ((NS_COUNT++)); NS_RESULTS+=("$result");;
        "TXT") ((TXT_COUNT++)); TXT_RESULTS+=("$result");;
        "SRV") ((SRV_COUNT++)); SRV_RESULTS+=("$result");;
        "PTR") ((PTR_COUNT++)); PTR_RESULTS+=("$result");;
        "SOA") ((SOA_COUNT++)); SOA_RESULTS+=("$result");;
    esac
}

# A Records
echo -e "${BLUE}🔍 A Records...${NC}"
progress_bar 1
while IFS= read -r ip; do
    if [[ -n "$ip" && "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        add_record "A" "$ip"
        echo -e "  ${GREEN}A${NC} → $ip"
    fi
done < <(dig +short A "$DOMAIN" 2>/dev/null)

# AAAA Records
echo -e "${BLUE}🔍 AAAA Records...${NC}"
progress_bar 1
while IFS= read -r ip; do
    if [[ -n "$ip" ]]; then
        add_record "AAAA" "$ip"
        echo -e "  ${GREEN}AAAA${NC} → $ip"
    fi
done < <(dig +short AAAA "$DOMAIN" 2>/dev/null)

# CNAME Records
echo -e "${BLUE}🔍 CNAME Records...${NC}"
progress_bar 1
while IFS= read -r cname; do
    if [[ -n "$cname" ]]; then
        add_record "CNAME" "$cname"
        echo -e "  ${PURPLE}CNAME${NC} → $cname"
    fi
done < <(dig +short CNAME "$DOMAIN" 2>/dev/null)

# MX Records
echo -e "${BLUE}🔍 MX Records...${NC}"
progress_bar 1
while IFS= read -r mx; do
    if [[ -n "$mx" ]]; then
        add_record "MX" "$mx"
        echo -e "  ${YELLOW}MX${NC} → $mx"
    fi
done < <(dig +short MX "$DOMAIN" 2>/dev/null)

# NS Records
echo -e "${BLUE}🔍 NS Records...${NC}"
progress_bar 1
while IFS= read -r ns; do
    if [[ -n "$ns" ]]; then
        # Remove trailing dot for consistency
        ns_clean="${ns%.}"
        add_record "NS" "$ns_clean"
        echo -e "  ${CYAN}NS${NC} → $ns_clean"
    fi
done < <(dig +short NS "$DOMAIN" 2>/dev/null)

# TXT Records
echo -e "${BLUE}🔍 TXT Records...${NC}"
progress_bar 1
while IFS= read -r txt; do
    if [[ -n "$txt" ]]; then
        add_record "TXT" "$txt"
        echo -e "  ${RED}TXT${NC} → $txt"
    fi
done < <(dig +short TXT "$DOMAIN" 2>/dev/null)

# SRV Records
echo -e "${BLUE}🔍 SRV Records...${NC}"
progress_bar 1
for service in "_ldap._tcp" "_sip._tcp" "_kerberos._tcp" "_http._tcp" "_https._tcp" "_imap._tcp" "_pop3._tcp" "_smtp._tcp"; do
    while IFS= read -r srv; do
        if [[ -n "$srv" ]]; then
            add_record "SRV" "$srv"
            echo -e "  ${CYAN}SRV${NC} → $srv"
        fi
    done < <(dig +short SRV "${service}.${DOMAIN}" 2>/dev/null)
done

# PTR Records (Reverse DNS)
echo -e "${BLUE}🔍 PTR Records...${NC}"
progress_bar 1
for ip in "${A_RESULTS[@]}"; do
    ptr_result=$(host "$ip" 2>/dev/null | grep -E 'domain name pointer' | head -1)
    if [[ -n "$ptr_result" ]]; then
        add_record "PTR" "$ptr_result"
        echo -e "  ${PURPLE}PTR${NC} → $ptr_result"
    fi
done

# SOA Records
echo -e "${BLUE}🔍 SOA Records...${NC}"
progress_bar 1
while IFS= read -r soa; do
    if [[ -n "$soa" ]]; then
        add_record "SOA" "$soa"
        echo -e "  ${GREEN}SOA${NC} → $soa"
    fi
done < <(dig +short SOA "$DOMAIN" 2>/dev/null)

# Zone Transfer
echo -e "${BLUE}🔍 Zone Transfer...${NC}"
progress_bar 2
for ns in "${NS_RESULTS[@]}"; do
    # Try zone transfer with each nameserver
    zone_result=$(dig axfr "$DOMAIN" "@${ns}" 2>/dev/null)
    if [[ -n "$zone_result" && "$zone_result" != *"Transfer failed"* ]]; then
        ZONE_TRANSFER_SUCCESS=1
        ZONE_TRANSFER_RESULTS+=("$zone_result")
        echo -e "  ${RED}✅ ZONE${NC} → Zone transfer successful from $ns"
    fi
done

# DNSSEC
echo -e "${BLUE}🔍 DNSSEC Validation...${NC}"
progress_bar 1
if dig +short DNSKEY "$DOMAIN" +dnssec 2>/dev/null | grep -q "257"; then
    DNSSEC_VALID=1
    echo -e "  ${GREEN}✅ DNSSEC${NC} → Valid DNSKEY found"
else
    echo -e "  ${RED}❌ DNSSEC${NC} → No DNSKEY records"
fi

# Summary
echo -e "\n${GREEN}══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}📊 ENUMERATION SUMMARY${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════════════${NC}"
printf "${CYAN}A:${NC} %2d | ${CYAN}AAAA:${NC} %2d | ${PURPLE}CNAME:${NC} %2d | ${YELLOW}MX:${NC} %2d\n" "$A_COUNT" "$AAAA_COUNT" "$CNAME_COUNT" "$MX_COUNT"
printf "${CYAN}NS:${NC} %2d | ${RED}TXT:${NC} %2d | ${CYAN}SRV:${NC} %2d | ${PURPLE}PTR:${NC} %2d\n" "$NS_COUNT" "$TXT_COUNT" "$SRV_COUNT" "$PTR_COUNT"
printf "${GREEN}SOA:${NC} %2d | ${RED}ZONE:${NC} %s | ${GREEN}DNSSEC:${NC} %s\n" "$SOA_COUNT" "$( [ $ZONE_TRANSFER_SUCCESS -eq 1 ] && echo "✅" || echo "❌" )" "$( [ $DNSSEC_VALID -eq 1 ] && echo "✅" || echo "❌" )"
echo -e "${GREEN}══════════════════════════════════════════════════════════${NC}"

# Generate HTML Report
cat > "$OUTPUT_FILE" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DNS Enumeration Report - ${DOMAIN}</title>
    <style>
        *{margin:0;padding:0;box-sizing:border-box;}
        body{font-family:'Segoe UI',Tahoma,Geneva,Verdana,sans-serif;background:linear-gradient(135deg,#0c0c0c 0%,#1a1a2e 50%,#16213e 100%);color:#fff;line-height:1.6;padding:20px;}
        .container{max-width:1400px;margin:0 auto;}
        .header{background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);padding:30px;border-radius:20px;margin-bottom:30px;box-shadow:0 20px 40px rgba(0,0,0,0.3);text-align:center;}
        .header h1{font-size:2.5em;margin-bottom:10px;}
        .summary-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:20px;margin-bottom:40px;}
        .card{background:linear-gradient(145deg,rgba(255,255,255,0.1),rgba(255,255,255,0.05));backdrop-filter:blur(10px);border-radius:20px;padding:25px;text-align:center;border:1px solid rgba(255,255,255,0.1);transition:all 0.3s ease;box-shadow:0 10px 30px rgba(0,0,0,0.2);}
        .card:hover{transform:translateY(-10px);box-shadow:0 20px 50px rgba(102,126,234,0.3);}
        .card h3{color:#667eea;margin-bottom:10px;font-size:1.2em;}
        .count{font-size:2.5em;font-weight:bold;margin-bottom:5px;}
        .section{background:linear-gradient(145deg,rgba(255,255,255,0.1),rgba(255,255,255,0.05));backdrop-filter:blur(10px);border-radius:20px;margin-bottom:30px;border:1px solid rgba(255,255,255,0.1);overflow:hidden;box-shadow:0 10px 30px rgba(0,0,0,0.2);}
        .section-header{background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);padding:20px 30px;font-size:1.4em;font-weight:bold;}
        .table-container{padding:30px;}
        table{width:100%;border-collapse:collapse;}
        th,td{padding:15px;text-align:left;border-bottom:1px solid rgba(255,255,255,0.1);}
        th{background:rgba(255,255,255,0.1);font-weight:600;}
        tr:hover{background:rgba(255,255,255,0.05);}
        .a{color:#4CAF50;}.aaaa{color:#2196F3;}.cname{color:#FF9800;}.mx{color:#FFC107;}
        .ns{color:#00BCD4;}.txt{color:#F44336;}.srv{color:#9C27B0;}.ptr{color:#E91E63;}
        .soa{color:#4CAF50;}
        .success{color:#4CAF50;}.failure{color:#F44336;}
    </style>
</head>
<body>
<div class="container">
<div class="header">
<h1>🔥 DNS Enumeration Report</h1>
<h2>Target: ${DOMAIN}</h2>
<p>Comprehensive DNS reconnaissance results</p>
</div>
<div class="summary-grid">
<div class="card"><h3>A Records</h3><div class="count a">${A_COUNT}</div></div>
<div class="card"><h3>AAAA Records</h3><div class="count aaaa">${AAAA_COUNT}</div></div>
<div class="card"><h3>CNAME Records</h3><div class="count cname">${CNAME_COUNT}</div></div>
<div class="card"><h3>MX Records</h3><div class="count mx">${MX_COUNT}</div></div>
<div class="card"><h3>NS Records</h3><div class="count ns">${NS_COUNT}</div></div>
<div class="card"><h3>TXT Records</h3><div class="count txt">${TXT_COUNT}</div></div>
<div class="card"><h3>SRV Records</h3><div class="count srv">${SRV_COUNT}</div></div>
<div class="card"><h3>PTR Records</h3><div class="count ptr">${PTR_COUNT}</div></div>
<div class="card"><h3>SOA Records</h3><div class="count soa">${SOA_COUNT}</div></div>
<div class="card"><h3>Zone Transfer</h3><div class="count $([ $ZONE_TRANSFER_SUCCESS -eq 1 ] && echo "success" || echo "failure")">$([ $ZONE_TRANSFER_SUCCESS -eq 1 ] && echo "✅" || echo "❌")</div></div>
<div class="card"><h3>DNSSEC</h3><div class="count $([ $DNSSEC_VALID -eq 1 ] && echo "success" || echo "failure")">$([ $DNSSEC_VALID -eq 1 ] && echo "✅" || echo "❌")</div></div>
</div>
EOF

# Function to add a section to HTML
add_html_section() {
    local title="$1"
    local count="$2"
    local color_class="$3"
    local results=("${!4}")
    
    cat >> "$OUTPUT_FILE" << EOF
<div class="section">
<div class="section-header">${title} (${count} found)</div>
<div class="table-container">
EOF
    
    if [ $count -gt 0 ]; then
        cat >> "$OUTPUT_FILE" << EOF
<table>
<tr><th>Records</th></tr>
EOF
        for result in "${results[@]}"; do
            # Escape any HTML special characters
            result_escaped=$(echo "$result" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
            cat >> "$OUTPUT_FILE" << EOF
<tr><td class="${color_class}">${result_escaped}</td></tr>
EOF
        done
        cat >> "$OUTPUT_FILE" << EOF
</table>
EOF
    else
        cat >> "$OUTPUT_FILE" << EOF
<p style="text-align:center;color:#888;padding:40px;">No records found</p>
EOF
    fi
    
    cat >> "$OUTPUT_FILE" << EOF
</div>
</div>
EOF
}

# Add all sections
add_html_section "🌐 A Records" "$A_COUNT" "a" A_RESULTS[@]
add_html_section "🌐 AAAA Records" "$AAAA_COUNT" "aaaa" AAAA_RESULTS[@]
add_html_section "🔗 CNAME Records" "$CNAME_COUNT" "cname" CNAME_RESULTS[@]
add_html_section "📧 MX Records" "$MX_COUNT" "mx" MX_RESULTS[@]
add_html_section "🌍 NS Records" "$NS_COUNT" "ns" NS_RESULTS[@]
add_html_section "📝 TXT Records" "$TXT_COUNT" "txt" TXT_RESULTS[@]
add_html_section "⚙️ SRV Records" "$SRV_COUNT" "srv" SRV_RESULTS[@]
add_html_section "🔍 PTR Records" "$PTR_COUNT" "ptr" PTR_RESULTS[@]
add_html_section "📋 SOA Records" "$SOA_COUNT" "soa" SOA_RESULTS[@]

# Zone Transfer section (if successful)
if [ $ZONE_TRANSFER_SUCCESS -eq 1 ]; then
    cat >> "$OUTPUT_FILE" << EOF
<div class="section">
<div class="section-header">🔄 Zone Transfer Results (Successful)</div>
<div class="table-container">
<table>
<tr><th>Zone Data</th></tr>
EOF
    for result in "${ZONE_TRANSFER_RESULTS[@]}"; do
        result_escaped=$(echo "$result" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' | tr '\n' '<br>')
        cat >> "$OUTPUT_FILE" << EOF
<tr><td class="success">${result_escaped}</td></tr>
EOF
    done
    cat >> "$OUTPUT_FILE" << EOF
</table>
</div>
</div>
EOF
fi

# Close HTML
cat >> "$OUTPUT_FILE" << 'EOF'
</div>
</body>
</html>
EOF

echo -e "\n${GREEN}✅ Report generated: ${CYAN}$OUTPUT_FILE${NC}"
echo -e "${GREEN}📁 Open in browser to view interactive results${NC}"
