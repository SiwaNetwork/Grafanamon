#!/bin/bash

# Создание точной копии timebeat-backend-chart с изменением имени

echo "Создание копии timebeat-backend-chart..."

# Удаляем старую копию если существует
rm -rf timebeat-backend-chart-copy

# Копируем оригинальный chart
cp -r timebeat-backend-chart timebeat-backend-chart-copy

# Переходим в копию
cd timebeat-backend-chart-copy

# Изменяем имя в Chart.yaml
echo "Изменение имени chart..."
sed -i 's/name: timebeat-backend-chart/name: shiwatime-backend-chart/' Chart.yaml

# Изменяем описание
sed -i 's/description: Grafana \/ Elasticsearch Backend for Timebeat Enterprise Clients/description: Grafana \/ Elasticsearch Backend for SHIWA TIME Platform/' Chart.yaml

# Изменяем иконку (опционально)
sed -i 's|icon: https://timebeat.app/assets/img/logo/logo.png|icon: https://shiwatime.io/logo.png|' Chart.yaml

# Обновляем комментарии в values.yaml
sed -i 's/# Default values for timebeat-backend-chart./# Default values for shiwatime-backend-chart./' values.yaml

echo "Копия создана в директории timebeat-backend-chart-copy"
echo ""
echo "Изменения:"
echo "- name: timebeat-backend-chart → shiwatime-backend-chart"
echo "- description: обновлено для SHIWA TIME"
echo "- icon: изменена на shiwatime.io/logo.png"
echo ""
echo "Все остальные файлы остались без изменений."