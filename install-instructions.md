# Инструкция по установке на сервер с использованием Helm чарта из GitHub

## Предварительные требования

- Сервер с установленной ОС Linux (RHEL/CentOS/Fedora или совместимые)
- Доступ к серверу с правами sudo
- Подключение к интернету

## Шаг 1: Установка snap

```bash
sudo dnf install -y snapd
```

После установки создайте символическую ссылку для классических snap-пакетов:

```bash
sudo ln -s /var/lib/snapd/snap /snap
```

## Шаг 2: Установка MicroK8s

```bash
sudo snap install microk8s --classic
```

## Шаг 3: Включение необходимых дополнений MicroK8s

```bash
# Включение DNS
sudo /snap/bin/microk8s enable dns

# Включение hostpath-storage для локального хранилища
sudo /snap/bin/microk8s enable hostpath-storage

# Включение Helm 3
sudo /snap/bin/microk8s enable helm3

# Включение MetalLB для балансировки нагрузки
sudo /snap/bin/microk8s enable metallb
```

**Важно:** При включении MetalLB вас попросят указать диапазон IP-адресов. 
Формат должен быть: `IP-адрес-IP-адрес` (например: `192.168.1.200-192.168.1.200`)

## Шаг 4: Установка вашего Helm чарта из GitHub

### Вариант 1: Клонирование репозитория и установка локально

```bash
# Клонирование репозитория
git clone https://github.com/SiwaNetwork/Grafanamon.git
cd Grafanamon

# Переход на нужную ветку
git checkout cursor/helm-d208

# Переход в директорию с Helm чартом
cd shiwatime-helm-chart

# Установка чарта
sudo /snap/bin/microk8s helm3 install shiwatime . --namespace shiwatime --create-namespace
```

### Вариант 2: Установка напрямую из GitHub (если чарт упакован)

```bash
# Если в репозитории есть упакованный .tgz файл чарта
sudo /snap/bin/microk8s helm3 install shiwatime https://raw.githubusercontent.com/SiwaNetwork/Grafanamon/cursor/helm-d208/shiwatime-helm-chart/shiwatime-0.1.0.tgz --namespace shiwatime --create-namespace
```

### Вариант 3: Добавление репозитория как Helm repository (если настроен GitHub Pages)

```bash
# Добавление репозитория
sudo /snap/bin/microk8s helm3 repo add shiwatime https://siwanetwork.github.io/Grafanamon/

# Обновление списка чартов
sudo /snap/bin/microk8s helm3 repo update

# Установка чарта
sudo /snap/bin/microk8s helm3 install shiwatime shiwatime/shiwatime-helm-chart --namespace shiwatime --create-namespace
```

## Шаг 5: Проверка установки

```bash
# Проверка статуса подов
sudo /snap/bin/microk8s kubectl get pods -n shiwatime

# Проверка сервисов
sudo /snap/bin/microk8s kubectl get svc -n shiwatime

# Просмотр логов (замените <pod-name> на имя вашего пода)
sudo /snap/bin/microk8s kubectl logs -n shiwatime <pod-name>
```

## Шаг 6: Настройка доступа (опционально)

Для удобства можно создать алиасы для команд MicroK8s:

```bash
# Добавьте в ~/.bashrc или ~/.bash_profile
alias kubectl='sudo /snap/bin/microk8s kubectl'
alias helm='sudo /snap/bin/microk8s helm3'

# Применить изменения
source ~/.bashrc
```

## Дополнительные команды

### Обновление чарта

```bash
# Из локальной директории
cd /path/to/Grafanamon/shiwatime-helm-chart
sudo /snap/bin/microk8s helm3 upgrade shiwatime . -n shiwatime

# Или с указанием values файла
sudo /snap/bin/microk8s helm3 upgrade shiwatime . -n shiwatime -f custom-values.yaml
```

### Удаление установки

```bash
sudo /snap/bin/microk8s helm3 uninstall shiwatime -n shiwatime
```

### Просмотр значений чарта

```bash
sudo /snap/bin/microk8s helm3 get values shiwatime -n shiwatime
```

## Примечания

1. **IP-адрес для MetalLB**: Убедитесь, что указанный IP-адрес не используется другими устройствами в вашей сети
2. **Namespace**: В примерах используется namespace `shiwatime`, вы можете изменить его на любой другой
3. **Проверка структуры чарта**: Перед установкой убедитесь, что в директории `shiwatime-helm-chart` есть файлы `Chart.yaml` и `values.yaml`
4. **Кастомизация**: Создайте файл `custom-values.yaml` для переопределения стандартных настроек чарта

## Устранение неполадок

### Если поды не запускаются

```bash
# Детальная информация о поде
sudo /snap/bin/microk8s kubectl describe pod <pod-name> -n shiwatime

# Проверка событий
sudo /snap/bin/microk8s kubectl get events -n shiwatime --sort-by='.lastTimestamp'
```

### Проверка конфигурации MicroK8s

```bash
sudo /snap/bin/microk8s status
sudo /snap/bin/microk8s inspect
```

### Логи MicroK8s

```bash
sudo journalctl -u snap.microk8s.daemon-kubelite -f
```