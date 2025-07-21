# Установка Shiwatime на сервер

Этот репозиторий содержит инструкции и скрипты для установки Shiwatime на сервер с использованием MicroK8s и Helm.

## Файлы в репозитории

### 📄 install-instructions.md
Подробная пошаговая инструкция по установке с объяснениями каждого шага. Включает:
- Установку необходимых компонентов (snapd, MicroK8s)
- Настройку MicroK8s с необходимыми дополнениями
- Три варианта установки Helm чарта из GitHub
- Команды для проверки и управления установкой
- Раздел устранения неполадок

### 🚀 install-shiwatime.sh
Автоматизированный скрипт установки, который:
- Проверяет права sudo
- Устанавливает все необходимые компоненты
- Предлагает выбор способа установки Helm чарта
- Создает удобные алиасы для kubectl и helm
- Проверяет успешность установки
- Выводит полезные команды для дальнейшей работы

**Использование:**
```bash
sudo ./install-shiwatime.sh
```

### ⚙️ custom-values-example.yaml
Пример файла для кастомизации параметров Helm чарта. Содержит настройки для:
- Репликации и масштабирования
- Docker образов
- Сетевых сервисов и Ingress
- Ресурсов (CPU/Memory)
- Хранилища данных
- Базы данных
- Мониторинга (Prometheus/Grafana)
- Безопасности

**Использование:**
```bash
cp custom-values-example.yaml custom-values.yaml
# Отредактируйте custom-values.yaml под ваши нужды
sudo /snap/bin/microk8s helm3 install shiwatime . -n shiwatime -f custom-values.yaml
```

## Быстрый старт

1. **Автоматическая установка:**
   ```bash
   sudo ./install-shiwatime.sh
   ```

2. **Ручная установка:**
   Следуйте инструкциям в файле `install-instructions.md`

## Требования

- Сервер с Linux (RHEL/CentOS/Fedora или совместимые)
- Права sudo
- Подключение к интернету
- Свободный IP-адрес для MetalLB (LoadBalancer)

## Полезные команды после установки

```bash
# Проверить статус подов
sudo /snap/bin/microk8s kubectl get pods -n shiwatime

# Посмотреть логи
sudo /snap/bin/microk8s kubectl logs -n shiwatime <pod-name>

# Получить информацию о сервисах
sudo /snap/bin/microk8s kubectl get svc -n shiwatime

# Обновить установку
sudo /snap/bin/microk8s helm3 upgrade shiwatime <path-to-chart> -n shiwatime

# Удалить установку
sudo /snap/bin/microk8s helm3 uninstall shiwatime -n shiwatime
```

## Поддержка

При возникновении проблем:
1. Проверьте раздел "Устранение неполадок" в `install-instructions.md`
2. Проверьте логи MicroK8s: `sudo journalctl -u snap.microk8s.daemon-kubelite -f`
3. Проверьте статус MicroK8s: `sudo /snap/bin/microk8s status`

## Лицензия

Эти скрипты предоставляются как есть для помощи в установке Shiwatime.
