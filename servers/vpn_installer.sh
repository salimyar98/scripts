#!/bin/bash

echo "=============================="
echo "   VPN УСТАНОВЩИК ДЛЯ UBUNTU"
echo "=============================="
echo
echo "Выберите тип VPN для установки:"
echo "1) PPTP (простой, но менее надежный)"
echo "2) L2TP/IPSec с PSK (надежнее)"
read -p "Введите 1 или 2 для выбора типа: " choice

read -p "Введите логин для VPN: " vpn_user
read -s -p "Введите пароль: " vpn_pass
echo

if [[ "$choice" == "2" ]]; then
  read -s -p "Введите PSK (предварительный ключ IPSec): " vpn_psk
  echo
fi

ip_public=$(curl -s ifconfig.me)

echo "Обновление пакетов..."
apt update -y

if [[ "$choice" == "1" ]]; then
  echo "[PPTP] Установка pptpd..."
  apt install -y pptpd netfilter-persistent

  echo "[PPTP] Настройка /etc/pptpd.conf..."
  cat > /etc/pptpd.conf <<EOF
localip 10.0.0.1
remoteip 10.0.0.100-200
EOF

  echo "[PPTP] Настройка /etc/ppp/pptpd-options..."
  cat > /etc/ppp/pptpd-options <<EOF
name pptpd
refuse-pap
refuse-chap
refuse-mschap
require-mschap-v2
require-mppe-128
ms-dns 8.8.8.8
ms-dns 1.1.1.1
proxyarp
lock
nobsdcomp
novj
novjccomp
nologfd
EOF

  echo "[PPTP] Добавление пользователя..."
  echo "$vpn_user pptpd $vpn_pass *" >> /etc/ppp/chap-secrets

  echo "[PPTP] Настройка NAT и IP forwarding..."
  echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
  sysctl -p
  iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
  iptables -A FORWARD -s 10.0.0.0/24 -j ACCEPT
  iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
  netfilter-persistent save

  systemctl restart pptpd
  systemctl enable pptpd

  echo
  echo "PPTP VPN успешно установлен!"
  echo "Сервер: $ip_public"
  echo "Логин: $vpn_user"
  echo "Пароль: $vpn_pass"

elif [[ "$choice" == "2" ]]; then
  echo "[L2TP] Установка strongSwan, xl2tpd..."
  apt install -y strongswan xl2tpd ppp lsof iptables-persistent

  echo "[L2TP] Конфигурация strongSwan..."
  cat > /etc/ipsec.conf <<EOF
config setup
    uniqueids=no

conn L2TP-PSK
    authby=secret
    pfs=no
    auto=add
    keyingtries=3
    rekey=no
    ike=aes256-sha1-modp1024!
    esp=aes256-sha1!
    type=transport
    left=%any
    leftprotoport=17/1701
    right=%any
    rightprotoport=17/%any
EOF

  cat > /etc/ipsec.secrets <<EOF
: PSK "$vpn_psk"
EOF

  echo "[L2TP] Настройка xl2tpd и PPP..."
  cat > /etc/xl2tpd/xl2tpd.conf <<EOF
[global]
port = 1701

[lns default]
ip range = 10.0.0.10-10.0.0.100
local ip = 10.0.0.1
require chap = yes
refuse pap = yes
require authentication = yes
name = L2TP-VPN
ppp debug = yes
pppoptfile = /etc/ppp/options.xl2tpd
length bit = yes
EOF

  cat > /etc/ppp/options.xl2tpd <<EOF
require-mschap-v2
ms-dns 8.8.8.8
ms-dns 1.1.1.1
asyncmap 0
auth
crtscts
lock
hide-password
modem
debug
name l2tpd
proxyarp
lcp-echo-interval 30
lcp-echo-failure 4
EOF

  echo "$vpn_user l2tpd $vpn_pass *" >> /etc/ppp/chap-secrets

  echo "[L2TP] Настройка NAT и IP forwarding..."
  echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
  sysctl -p
  iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
  iptables -A FORWARD -s 10.0.0.0/24 -j ACCEPT
  iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
  netfilter-persistent save

  systemctl restart strongswan-starter
  systemctl enable strongswan-starter
  systemctl restart xl2tpd
  systemctl enable xl2tpd

  echo
  echo "L2TP/IPSec VPN успешно установлен!"
  echo "Сервер: $ip_public"
  echo "Логин: $vpn_user"
  echo "Пароль: $vpn_pass"
  echo "PSK: $vpn_psk"

else
  echo "Неверный выбор. Скрипт завершён."
  exit 1
fi
