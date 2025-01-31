# Налаштування моніторингу Nginx з використанням Prometheus, Grafana, Loki та Promtail

## 📌 1. Опис завдання

Ми налаштували систему моніторингу для вебсервера Nginx, використовуючи стек Prometheus + Grafana + Loki. Моніторинг збирає як метрики, так і логи сервера.

## 🔧 2. Інфраструктура

Для розгортання використовували AWS EC2:

- **Моніторинг-сервер**: де працюють Prometheus, Grafana, Loki.
- **Клієнт (вебсервер)**: на якому встановлено Nginx, `node_exporter` та `promtail`.

Обидва сервери знаходяться в одній VPC.

## 🏗 3. Створення інстансів

### Моніторинг-сервер:

- Тип: `t3.small`.
- Порти:
  - 22 (SSH)
  - 9090 (Prometheus)
  - 3000 (Grafana)
  - 3100 (Loki)
- ОС: Ubuntu 20.04.

### Вебсервер:

- Тип: `t3.micro`.
- Порти:
  - 22 (SSH)
  - 80 (Nginx)
  - 9100 (Node Exporter)
  - 9113 (Nginx Exporter)
- ОС: Ubuntu 20.04.

## 🚀 4. Налаштування клієнта (вебсервера)

### 4.1 Установка Nginx

```bash
sudo apt update && sudo apt install -y nginx
sudo systemctl enable nginx --now
```

### 4.2 Встановлення Node Exporter

```bash
wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz
tar xvf node_exporter-1.5.0.linux-amd64.tar.gz
sudo mv node_exporter-1.5.0.linux-amd64/node_exporter /usr/local/bin/
```

Створюємо `systemd` сервіс:

```bash
sudo tee /etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=root
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
EOF
```

```bash
sudo systemctl enable --now node_exporter
```
![Alt-текст](<4.png>)

### 4.3 Встановлення Nginx Exporter

```bash
wget https://github.com/nginxinc/nginx-prometheus-exporter/releases/download/v1.1.0/nginx-prometheus-exporter-1.1.0.linux-amd64.tar.gz
tar xvf nginx-prometheus-exporter-1.1.0.linux-amd64.tar.gz
sudo mv nginx-prometheus-exporter /usr/local/bin/
```

Створюємо `systemd` сервіс:

```bash
sudo tee /etc/systemd/system/nginx_exporter.service <<EOF
[Unit]
Description=Nginx Prometheus Exporter
After=network.target

[Service]
User=root
ExecStart=/usr/local/bin/nginx-prometheus-exporter -nginx.scrape-uri http://127.0.0.1/stub_status

[Install]
WantedBy=default.target
EOF
```
Змінюємо конфіг nginx

![Alt-текст](<3.png>)

```bash
sudo systemctl enable --now nginx_exporter
```
![Alt-текст](<2.png>)
### 4.4 Встановлення Promtail

```bash
wget https://github.com/grafana/loki/releases/download/v2.9.0/promtail-linux-amd64.zip
unzip promtail-linux-amd64.zip
sudo mv promtail-linux-amd64 /usr/local/bin/promtail
```

Конфігурація `promtail.yml`:

```yaml
server:
  http_listen_address: 0.0.0.0
  http_listen_port: 9080

clients:
  - url: http://<Monitoring_IP>:3100/loki/api/v1/push

scrape_configs:
  - job_name: "nginx_logs"
    static_configs:
      - targets:
          - localhost
        labels:
          job: "nginx_access"
          __path__: /var/log/nginx/*.log
```

Запускаємо `promtail`:

```bash
sudo promtail -config.file /etc/promtail.yml &
```
![Alt-текст](<1.png>)
---

## 📡 5. Налаштування сервера моніторингу

### 5.1 Завантаження репозиторію

```bash
git clone https://github.com/your-repo/grafana_stack_for_docker.git
cd grafana_stack_for_docker
```

### 5.2 Налаштування Docker

```bash
sudo apt update && sudo apt install -y docker.io docker-compose
sudo systemctl enable --now docker
```

Запускаємо стек:

```bash
docker-compose up -d
```

### 5.3 Налаштування Prometheus

Файл `prometheus.yml`:

```yaml
scrape_configs:
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['<Client_IP>:9100']
  
  - job_name: 'nginx_exporter'
    static_configs:
      - targets: ['<Client_IP>:9113']
```

### 5.4 Налаштування Loki

Файл `loki-config.yml`:

```yaml
server:
  http_listen_port: 3100

ingester:
  lifecycler:
    address: 127.0.0.1
    ring:
      kvstore:
        store: inmemory
```

### 5.5 Налаштування Grafana

1. Відкриваємо: `http://<Monitoring_Server_IP>:3000`
2. Додаємо джерела даних:
   - **Prometheus**: `http://prometheus:9090`
   - **Loki**: `http://loki:3100`

![Alt-текст](<5.png>)

3. Імпортуємо дашборди:
   - Node Exporter (ID: 1860)
   - Nginx Dashboard
   - Loki Logs Explorer

![Alt-текст](<12.png>)

![Alt-текст](<6.png>)

Для нжинкс дашборд виявився кривуватим, але не стала виправляти, дуже багато часу треба підігнати дашборд під свою версію графани

![Alt-текст](<7.png>)

Проте упевнилася, що дані збираються, зробивши квері у прометеусіЖ

![Alt-текст](<8.png>)
---

## ✅ 6. Перевірка збору метрик

### 6.1 Перевірка Prometheus

```bash
curl -s http://localhost:9090/api/v1/targets | jq .
```

### 6.2 Перевірка Loki

```bash
curl -s http://localhost:3100/loki/api/v1/labels | jq .
```

### 6.3 Перевірка логів у Grafana

У Grafana відкриваємо `Explore`, вибираємо `Loki` і запускаємо запит:

```logql
{job="nginx_access"}
```
![Alt-текст](<9.png>)

І так як для локі дашборд не знайшовся, створили його самостійно

![Alt-текст](<10.png>)
![Alt-текст](<11.png>)

---

## 🎯 Висновок

Налаштовано повний стек моніторингу для Nginx із метриками та логами. Prometheus збирає метрики, Loki - логи, а Grafana забезпечує візуалізацію даних. 🎉
