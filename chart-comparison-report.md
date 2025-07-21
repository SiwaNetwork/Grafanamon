# Сравнение Helm Charts: timebeat-backend-chart vs shiwatime-backend-chart

## Обзор

Этот документ содержит детальное сравнение двух Helm charts:
- **timebeat-backend-chart** (версия 1.2.4) - оригинальный chart от Timebeat
- **shiwatime-backend-chart** (версия 1.0.0) - ваш адаптированный chart

## Основные различия

### 1. Chart.yaml

**timebeat-backend-chart:**
- Имя: `timebeat-backend-chart`
- Версия: 1.2.4
- App версия: 3.0.3
- Описание: "Grafana / Elasticsearch Backend for Timebeat Enterprise Clients"
- Минимальная конфигурация (8 строк)

**shiwatime-backend-chart:**
- Имя: `shiwatime-backend-chart` ✅ (изменено название)
- Версия: 1.0.0
- App версия: 1.0.0
- Описание: "SHIWA TIME Management Platform - Modern metrics collection and monitoring system"
- Расширенная конфигурация с keywords, maintainers, sources (21 строка)

### 2. Values.yaml

**timebeat-backend-chart:**
- Базовый шаблон values.yaml (84 строки)
- Использует стандартные настройки для nginx
- Минимальная конфигурация сервисов
- Нет специфичных настроек для Elasticsearch/Grafana

**shiwatime-backend-chart:**
- Расширенный values.yaml (243 строки)
- Детальная конфигурация для:
  - Elasticsearch (с настройками памяти, CPU, storage)
  - Grafana (с datasources, dashboards, plugins)
  - Prometheus (дополнительный компонент)
- Использует `storageClass: "microk8s-hostpath"`
- LoadBalancer сервисы для Elasticsearch и Grafana

### 3. Templates

**timebeat-backend-chart (7 файлов):**
- elasticsearch-deployment.yaml
- elasticsearch-service.yaml
- grafana-deployment.yaml
- grafana-service.yaml
- grafana-storage-persistentvolumeclaim.yaml
- kibana-deployment.yaml
- kibana-service.yaml

**shiwatime-backend-chart (11 файлов):**
- NOTES.txt (инструкции после установки)
- _helpers.tpl (вспомогательные функции)
- branding-configmap.yaml (кастомный брендинг)
- elasticsearch-service.yaml ✅
- elasticsearch-statefulset.yaml (вместо deployment)
- grafana-configmap.yaml (расширенная конфигурация)
- grafana-deployment.yaml ✅
- grafana-pvc.yaml (вместо отдельного PVC)
- grafana-service.yaml ✅
- namespace.yaml (создание namespace)
- shiwatime-dashboards-configmap.yaml (кастомные дашборды)

## Ключевые отличия в архитектуре

1. **Elasticsearch**: 
   - timebeat: использует Deployment
   - shiwatime: использует StatefulSet (более подходящий для stateful приложений)

2. **Компоненты**:
   - timebeat: Elasticsearch + Grafana + Kibana
   - shiwatime: Elasticsearch + Grafana + Prometheus (без Kibana)

3. **Конфигурация**:
   - timebeat: минимальная
   - shiwatime: расширенная с кастомизацией, брендингом и дашбордами

4. **Storage**:
   - timebeat: базовый PVC для Grafana
   - shiwatime: настроенный под microk8s с указанием storageClass

## Вывод

Ваш shiwatime-backend-chart является существенно переработанной версией timebeat-backend-chart с:
- ✅ Измененным названием (как требовалось)
- Более продвинутой архитектурой (StatefulSet для Elasticsearch)
- Расширенной конфигурацией
- Дополнительными компонентами (Prometheus вместо Kibana)
- Кастомным брендингом и дашбордами
- Адаптацией под microk8s окружение

Chart не является полной копией, а представляет собой улучшенную и адаптированную версию под ваши нужды.