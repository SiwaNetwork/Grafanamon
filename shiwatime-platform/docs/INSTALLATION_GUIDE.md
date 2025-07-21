# Руководство по установке ShiwaTime Management Platform

## Содержание

1. [Введение](#введение)
2. [Системные требования](#системные-требования)
3. [Подготовка к установке](#подготовка-к-установке)
4. [Установка с помощью Docker Compose](#установка-с-помощью-docker-compose)
5. [Установка в Kubernetes](#установка-в-kubernetes)
6. [Настройка после установки](#настройка-после-установки)
7. [Проверка работоспособности](#проверка-работоспособности)
8. [Решение проблем](#решение-проблем)
9. [Обновление платформы](#обновление-платформы)
10. [Резервное копирование](#резервное-копирование)

## Введение

ShiwaTime Management Platform - это комплексное решение для мониторинга и управления временными метриками, построенное на базе современных технологий:

- **Grafana** - визуализация данных и дашборды
- **Prometheus** - сбор и хранение метрик
- **PostgreSQL** - основная база данных
- **Redis** - кеширование данных
- **Alertmanager** - управление уведомлениями

## Системные требования

### Минимальные требования

- **ОС**: Linux (Ubuntu 20.04+, CentOS 7+, Debian 10+) или Windows Server 2019+
- **CPU**: 2 ядра
- **RAM**: 4 GB
- **Диск**: 20 GB свободного места
- **Docker**: версия 20.10+
- **Docker Compose**: версия 1.27+ или Docker Compose V2

### Рекомендуемые требования

- **ОС**: Ubuntu 22.04 LTS или RHEL 8+
- **CPU**: 4 ядра
- **RAM**: 8 GB
- **Диск**: 50 GB SSD
- **Сеть**: статический IP-адрес

### Необходимые порты

Убедитесь, что следующие порты доступны:

| Порт | Сервис | Описание |
|------|--------|----------|
| 80 | Nginx | HTTP (опционально) |
| 443 | Nginx | HTTPS (опционально) |
| 3000 | Grafana | Веб-интерфейс Grafana |
| 8080 | API | ShiwaTime API |
| 9090 | Prometheus | Веб-интерфейс Prometheus |
| 9093 | Alertmanager | Веб-интерфейс Alertmanager |
| 5432 | PostgreSQL | База данных |
| 6379 | Redis | Кеш |

## Подготовка к установке

### 1. Установка Docker

#### Ubuntu/Debian:

```bash
# Обновление пакетов
sudo apt-get update
sudo apt-get upgrade -y

# Установка необходимых пакетов
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Добавление GPG ключа Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Добавление репозитория Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Установка Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Добавление пользователя в группу docker
sudo usermod -aG docker $USER

# Перезагрузка или выход/вход для применения изменений группы
```

#### CentOS/RHEL:

```bash
# Установка необходимых пакетов
sudo yum install -y yum-utils

# Добавление репозитория Docker
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

# Установка Docker
sudo yum install -y docker-ce docker-ce-cli containerd.io

# Запуск Docker
sudo systemctl start docker
sudo systemctl enable docker

# Добавление пользователя в группу docker
sudo usermod -aG docker $USER
```

### 2. Установка Docker Compose

```bash
# Загрузка последней версии Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Установка прав на выполнение
sudo chmod +x /usr/local/bin/docker-compose

# Проверка установки
docker-compose --version
```

### 3. Настройка системы

```bash
# Увеличение лимитов для Elasticsearch
sudo sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf

# Настройка лимитов файловых дескрипторов
echo "* soft nofile 65536" | sudo tee -a /etc/security/limits.conf
echo "* hard nofile 65536" | sudo tee -a /etc/security/limits.conf
```

## Установка с помощью Docker Compose

### 1. Клонирование репозитория

```bash
# Клонирование репозитория
git clone https://github.com/your-org/shiwatime-platform.git
cd shiwatime-platform
```

### 2. Автоматическая установка

Используйте готовый скрипт установки:

```bash
# Запуск скрипта установки
cd scripts
sudo ./install.sh
```

Скрипт автоматически:
- Проверит наличие всех зависимостей
- Создаст необходимые директории
- Сгенерирует безопасные пароли
- Настроит firewall
- Запустит все сервисы
- Настроит Grafana

### 3. Ручная установка

Если вы предпочитаете ручную установку:

```bash
# Создание директорий для данных
mkdir -p data/{postgres,prometheus,grafana,alertmanager,redis}
mkdir -p logs

# Создание файла с переменными окружения
cat > .env << EOF
DB_PASSWORD=your_secure_password_here
GRAFANA_PASSWORD=your_grafana_password_here
EOF

# Установка прав доступа
chmod 600 .env
chmod -R 755 data/

# Запуск платформы
cd docker
docker-compose up -d

# Проверка статуса
docker-compose ps
```

## Установка в Kubernetes

### 1. Подготовка кластера

```bash
# Создание namespace
kubectl apply -f kubernetes/namespace.yaml

# Создание ConfigMap
kubectl apply -f kubernetes/configmap.yaml
```

### 2. Создание секретов

```bash
# Создание секрета для паролей
kubectl create secret generic shiwatime-secrets \
  --from-literal=db-password=your_secure_password \
  --from-literal=grafana-password=your_grafana_password \
  -n shiwatime
```

### 3. Развертывание с помощью Helm

```bash
# Добавление репозитория Helm
helm repo add shiwatime https://charts.shiwatime.io
helm repo update

# Установка
helm install shiwatime shiwatime/shiwatime-platform \
  --namespace shiwatime \
  --values values.yaml
```

### 4. Развертывание с помощью kubectl

```bash
# Применение всех манифестов
kubectl apply -f kubernetes/
```

## Настройка после установки

### 1. Первый вход в Grafana

1. Откройте браузер и перейдите по адресу: `http://your-server-ip:3000`
2. Используйте логин: `admin`
3. Используйте пароль из файла `.env` или из вывода скрипта установки
4. При первом входе система попросит сменить пароль

### 2. Импорт дашбордов

Дашборды автоматически импортируются при запуске. Вы найдете их в папке "ShiwaTime".

### 3. Настройка уведомлений

#### Email уведомления:

1. Отредактируйте файл `config/alertmanager.yml`
2. Укажите ваш SMTP сервер:

```yaml
global:
  smtp_smarthost: 'smtp.gmail.com:587'
  smtp_from: 'alerts@your-domain.com'
  smtp_auth_username: 'your-email@gmail.com'
  smtp_auth_password: 'your-app-password'
```

3. Перезапустите Alertmanager:

```bash
docker-compose restart alertmanager
```

### 4. Настройка SSL/TLS

Для production окружения рекомендуется настроить SSL:

```bash
# Установка Certbot
sudo apt-get install certbot

# Получение сертификата
sudo certbot certonly --standalone -d your-domain.com

# Настройка Nginx (пример конфигурации в docs/nginx-ssl.conf)
```

## Проверка работоспособности

### 1. Проверка статуса сервисов

```bash
# Проверка статуса контейнеров
docker-compose ps

# Проверка логов
docker-compose logs -f grafana
docker-compose logs -f prometheus
docker-compose logs -f shiwatime-api
```

### 2. Проверка доступности веб-интерфейсов

- Grafana: http://your-server:3000
- Prometheus: http://your-server:9090
- Alertmanager: http://your-server:9093
- API: http://your-server:8080/health

### 3. Проверка метрик

В Prometheus перейдите в раздел "Targets" и убедитесь, что все endpoints имеют статус "UP".

## Решение проблем

### Проблема: Grafana не запускается

```bash
# Проверка логов
docker-compose logs grafana

# Проверка прав доступа
sudo chown -R 472:472 data/grafana

# Перезапуск
docker-compose restart grafana
```

### Проблема: Prometheus не собирает метрики

```bash
# Проверка конфигурации
docker-compose exec prometheus promtool check config /etc/prometheus/prometheus.yml

# Проверка сети
docker network ls
docker network inspect shiwatime-platform_shiwatime-network
```

### Проблема: База данных не доступна

```bash
# Проверка логов PostgreSQL
docker-compose logs postgres

# Проверка подключения
docker-compose exec postgres psql -U shiwatime -d shiwatime -c "SELECT 1;"
```

## Обновление платформы

### 1. Резервное копирование

```bash
# Остановка сервисов
docker-compose stop

# Резервное копирование данных
tar -czf backup-$(date +%Y%m%d-%H%M%S).tar.gz data/

# Резервное копирование конфигурации
cp -r config/ config-backup-$(date +%Y%m%d-%H%M%S)/
```

### 2. Обновление

```bash
# Получение последних изменений
git pull origin main

# Обновление образов
docker-compose pull

# Запуск обновленной версии
docker-compose up -d

# Проверка статуса
docker-compose ps
```

## Резервное копирование

### Автоматическое резервное копирование

Создайте cron задачу для автоматического резервного копирования:

```bash
# Откройте crontab
crontab -e

# Добавьте строку для ежедневного резервного копирования в 2:00
0 2 * * * /path/to/shiwatime-platform/scripts/backup.sh
```

### Ручное резервное копирование

```bash
# Создание полного бэкапа
./scripts/backup.sh

# Восстановление из бэкапа
./scripts/restore.sh backup-20240101-020000.tar.gz
```

## Поддержка

Если у вас возникли проблемы:

1. Проверьте логи: `docker-compose logs`
2. Проверьте [FAQ](FAQ.md)
3. Создайте issue в репозитории проекта
4. Обратитесь в службу поддержки: support@shiwatime.io

---

© 2024 ShiwaTime Management Platform. Все права защищены.