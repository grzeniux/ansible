#!/bin/bash
# List USB Serial devices using udevadm
# This script scans for USB serial devices and displays their vendor/product/serial info

echo "📱 USB Serial Devices detected:"
echo "════════════════════════════════"

found=0
for tty in /dev/ttyUSB* /dev/ttyACM*; do
    if [ ! -e "$tty" ]; then
        continue
    fi
    
    found=$((found + 1))
    echo ""
    echo "Device: $tty"
    
    # Get manufacturer
    manufacturer=$(udevadm info -a -n "$tty" 2>/dev/null | grep "ATTRS{manufacturer}" | head -1 | sed 's/.*ATTRS{manufacturer}=="//' | sed 's/".*//')
    [ -n "$manufacturer" ] && echo "  Manufacturer: $manufacturer"
    
    # Get vendor ID and product ID
    vendor=$(udevadm info -a -n "$tty" 2>/dev/null | grep "ATTRS{idVendor}" | head -1 | sed 's/.*ATTRS{idVendor}=="//' | sed 's/".*//')
    product=$(udevadm info -a -n "$tty" 2>/dev/null | grep "ATTRS{idProduct}" | head -1 | sed 's/.*ATTRS{idProduct}=="//' | sed 's/".*//')
    [ -n "$vendor" ] && echo "  Vendor ID:     $vendor"
    [ -n "$product" ] && echo "  Product ID:    $product"
    
    # Get serial number
    serial=$(udevadm info -a -n "$tty" 2>/dev/null | grep "ATTRS{serial}" | head -1 | sed 's/.*ATTRS{serial}=="//' | sed 's/".*//')
    [ -n "$serial" ] && echo "  Serial:        $serial"
done

if [ $found -eq 0 ]; then
    echo "❌ No USB serial devices found"
else
    echo ""
    echo "════════════════════════════════"
    echo "✅ Found $found device(s)"
fi
