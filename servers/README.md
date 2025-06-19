# 🧰 Scripts for Server

<details>
<summary> 🚀 VPN Installer for Ubuntu (PPTP & L2TP/IPSec)</summary>

Скрипт для быстрой установки VPN-сервера на Ubuntu 20.04/22.04. Поддерживает:

- ✅ PPTP VPN — простой, но небезопасный (для старых клиентов)
- ✅ L2TP/IPSec VPN с Pre-Shared Key (PSK) — более надёжный вариант

---

## 📦 Что делает скрипт

- Устанавливает нужные пакеты (`pptpd`, `xl2tpd`, `strongswan`, `ppp`, `iptables-persistent`)
- Настраивает VPN-конфиги
- Добавляет пользователя (логин/пароль)
- (для L2TP) Добавляет PSK (предварительный ключ)
- Настраивает IP Forwarding и NAT (`iptables`)
- Сохраняет правила через `netfilter-persistent`
- Определяет внешний IP сервера
- Показывает итоговые данные для подключения

---

## ⚙️ Требования

- Ubuntu 20.04 или 22.04
- Права `root` или запуск через `sudo`
- Внешний (публичный) IP-адрес

---

## 📥 Установка

1. Скачай и дай права на выполнение:

```bash
wget https://your-url/vpn_installer.sh
chmod +x vpn_installer.sh
sudo ./vpn_installer.sh