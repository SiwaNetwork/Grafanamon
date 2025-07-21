# ShiwaTime Management Platform

<p align="center">
  <img src="docs/images/shiwatime-logo.png" alt="ShiwaTime Logo" width="300">
</p>

<p align="center">
  <strong>Современная платформа для мониторинга и управления временными метриками</strong>
</p>

<p align="center">
  <a href="#особенности">Особенности</a> •
  <a href="#быстрый-старт">Быстрый старт</a> •
  <a href="#документация">Документация</a> •
  <a href="#поддержка">Поддержка</a>
</p>

---

## О проекте

ShiwaTime Management Platform - это комплексное решение для мониторинга, анализа и визуализации временных метрик. Платформа построена на базе проверенных open-source технологий и предоставляет мощные инструменты для отслеживания производительности систем в реальном времени.

## Особенности

### 🚀 Производительность
- Высокопроизводительный сбор метрик с минимальной задержкой
- Оптимизированное хранение данных с автоматическим сжатием
- Поддержка горизонтального масштабирования

### 📊 Визуализация
- Красивые и информативные дашборды на базе Grafana
- Кастомная страница загрузки с брендингом SHIWA TIME
- Готовые шаблоны дашбордов для различных сценариев использования

### 🔔 Мониторинг и алерты
- Гибкая система правил оповещений
- Интеграция с email, Slack, Telegram и другими каналами
- Автоматическое обнаружение аномалий

### 🔒 Безопасность
- Поддержка SSL/TLS шифрования
- Ролевая модель доступа (RBAC)
- Аудит всех действий пользователей

### 🛠 Простота развертывания
- Установка одной командой
- Поддержка Docker и Kubernetes
- Автоматическая настройка всех компонентов

## Архитектура

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│   Grafana UI    │────▶│   Prometheus    │────▶│  ShiwaTime API  │
│                 │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
         │                       │                        │
         │                       │                        │
         ▼                       ▼                        ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│  AlertManager   │     │     Redis       │     │   PostgreSQL    │
│                 │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

## Компоненты

- **Grafana** - визуализация данных и дашборды
- **Prometheus** - сбор и хранение временных рядов
- **PostgreSQL** - реляционная база данных для метаданных
- **Redis** - кеширование и очереди сообщений
- **AlertManager** - управление уведомлениями
- **Node Exporter** - сбор системных метрик

## Быстрый старт

### Требования

- Docker 20.10+
- Docker Compose 1.27+
- 4GB RAM минимум
- 20GB свободного места на диске

### Установка

1. Клонируйте репозиторий:
```bash
git clone https://github.com/your-org/shiwatime-platform.git
cd shiwatime-platform
```

2. Запустите скрипт установки:
```bash
cd scripts
sudo ./install.sh
```

3. Откройте Grafana в браузере:
```
http://localhost:3000
```

Используйте учетные данные, показанные после установки.

### Docker Compose (ручная установка)

```bash
cd docker
docker-compose up -d
```

### Kubernetes

```bash
kubectl apply -f kubernetes/
```

## Конфигурация

### Переменные окружения

Создайте файл `.env` в корне проекта:

```env
DB_PASSWORD=your_secure_password
GRAFANA_PASSWORD=your_grafana_password
```

### Настройка метрик

Отредактируйте `prometheus/prometheus.yml` для добавления новых источников метрик.

### Настройка алертов

Правила алертов находятся в `prometheus/alert_rules.yml`.

## Документация

- [Руководство по установке](docs/INSTALLATION_GUIDE.md)
- [Руководство пользователя](docs/USER_GUIDE.md)
- [API документация](docs/API.md)
- [FAQ](docs/FAQ.md)

## Скриншоты

### Главный дашборд
![Dashboard](docs/images/dashboard.png)

### Страница загрузки
![Loading](docs/images/loading.png)

### Мониторинг системы
![Monitoring](docs/images/monitoring.png)

## Разработка

### Структура проекта

```
shiwatime-platform/
├── docker/              # Docker конфигурации
├── kubernetes/          # Kubernetes манифесты
├── grafana/            # Дашборды и провижининг Grafana
├── prometheus/         # Конфигурация Prometheus
├── config/             # Конфигурационные файлы
├── scripts/            # Утилиты и скрипты
├── docs/               # Документация
└── README.md
```

### Вклад в проект

Мы приветствуем вклад в развитие проекта! Пожалуйста:

1. Форкните репозиторий
2. Создайте ветку для вашей функции (`git checkout -b feature/AmazingFeature`)
3. Закоммитьте изменения (`git commit -m 'Add some AmazingFeature'`)
4. Запушьте в ветку (`git push origin feature/AmazingFeature`)
5. Откройте Pull Request

## Поддержка

- 📧 Email: support@shiwatime.io
- 💬 Telegram: [@shiwatime_support](https://t.me/shiwatime_support)
- 📚 Wiki: [wiki.shiwatime.io](https://wiki.shiwatime.io)
- 🐛 Issues: [GitHub Issues](https://github.com/your-org/shiwatime-platform/issues)

## Лицензия

Этот проект лицензирован под Apache License 2.0 - см. файл [LICENSE](LICENSE) для деталей.

## Благодарности

- Команде Grafana за отличный инструмент визуализации
- Команде Prometheus за надежную систему мониторинга
- Всем контрибьюторам и пользователям платформы

---

<p align="center">
  Сделано с ❤️ командой ShiwaTime
</p>