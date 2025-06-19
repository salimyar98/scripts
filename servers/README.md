# 🧰 Scripts for Server

<details>
<summary> 🚀 VPN Installer for Ubuntu (PPTP & L2TP/IPSec)</summary>

Скрипт для быстрой установки VPN-сервера на Ubuntu. Поддерживает:

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

- Ubuntu
- Права `root` или запуск через `sudo`
- Внешний (публичный) IP-адрес

---

## 📥 Установка

1. Скачай и дай права на выполнение:

```bash
wget https://raw.githubusercontent.com/salimyar98/scripts/main/servers/vpn_installer.sh
chmod +x vpn_installer.sh
sudo ./vpn_installer.sh
```

---

## 🛠️ Использование

### Скрипт при запуске предложит:
- Выбрать тип VPN:
  - 1 — PPTP
  - 2 — L2TP/IPSec с PSK
- Ввести логин
- Ввести пароль
- (для L2TP) Ввести PSK (ключ)

### После установки выведет:
- Публичный IP сервера
- Логин
- Пароль
- PSK (если выбран L2TP)

---

## 🔓 Порты и NAT

### Скрипт автоматически:
- Включает net.ipv4.ip_forward
- Добавляет правила iptables:
  - NAT (MASQUERADE)
  - FORWARD для клиентской сети
- Сохраняет правила (netfilter-persistent)
- UFW не трогает — если используется, порты откройте вручную.

### Используемые порты:
| Протокол | Порт  |     Назначение      |
|:--------:|:-----:|:-------------------:|
|   TCP    | 1723  |        PPTP         |
|   GRE    |   —   | PPTP (протокол 47)  |
|   UDP    |  500  |     IPsec (IKE)     |
|   UDP    | 4500  | IPsec NAT Traversal |
|   UDP    | 1701  |        L2TP         |

---

## ❗ Безопасность
- ⚠️ PPTP — устарел и уязвим. Использовать только в закрытых сетях или для теста.
- ✅ L2TP/IPSec безопаснее, но WireGuard/OpenVPN — ещё надёжнее.
- 🔐 Скрипт не включает брандмауэр — защищай сервер самостоятельно!

---

## 🧪 Проверка подключения

### После подключения клиента (например, роутера):

```bash
# Проверить активные ppp-сессии
ps aux | grep pppd
ip a show ppp+

# Проверить логи
journalctl -u pptpd -f
journalctl -u xl2tpd -f
journalctl -u strongswan-starter -f
```
---

## 🧹 Удаление (опционально)

```bash
systemctl disable --now pptpd
systemctl disable --now strongswan-starter
systemctl disable --now xl2tpd
```
И при необходимости — очистить конфигурации вручную.
