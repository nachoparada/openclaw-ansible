#!/bin/bash
cat << 'BANNER'
[0;36m
   +====================================================+
   |                                                    |
   |         [0;33mWelcome to OpenClaw![0;36m                        |
   |                                                    |
   |           [0;32mInstallation Successful![0;36m                  |
   |                                                    |
   +====================================================+[0m
BANNER

echo ""
echo "Security Status:"
echo "  - UFW Firewall: ENABLED"
echo "  - Open Ports: SSH (22) + Tailscale (41641/udp)"
echo "  - Docker isolation: ACTIVE"
echo ""
echo "Documentation: https://docs.openclaw.ai"
echo ""
