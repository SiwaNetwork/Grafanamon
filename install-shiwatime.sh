#!/bin/bash

# Скрипт автоматической установки Shiwatime на сервер
# Использует MicroK8s и Helm для развертывания

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Функция для вывода сообщений
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Проверка прав sudo
check_sudo() {
    if [ "$EUID" -ne 0 ]; then 
        log_error "Пожалуйста, запустите скрипт с правами sudo"
        exit 1
    fi
}

# Установка snapd
install_snapd() {
    log_info "Установка snapd..."
    dnf install -y snapd || {
        log_error "Не удалось установить snapd"
        exit 1
    }
    
    log_info "Создание символической ссылки для snap..."
    ln -s /var/lib/snapd/snap /snap 2>/dev/null || log_warn "Символическая ссылка уже существует"
}

# Установка MicroK8s
install_microk8s() {
    log_info "Установка MicroK8s..."
    snap install microk8s --classic || {
        log_error "Не удалось установить MicroK8s"
        exit 1
    }
    
    # Добавление текущего пользователя в группу microk8s
    usermod -a -G microk8s $SUDO_USER 2>/dev/null || log_warn "Не удалось добавить пользователя в группу microk8s"
}

# Включение дополнений MicroK8s
enable_addons() {
    log_info "Включение DNS..."
    /snap/bin/microk8s enable dns
    
    log_info "Включение hostpath-storage..."
    /snap/bin/microk8s enable hostpath-storage
    
    log_info "Включение Helm3..."
    /snap/bin/microk8s enable helm3
    
    log_info "Включение MetalLB..."
    log_warn "Вам нужно будет ввести диапазон IP-адресов для MetalLB"
    log_warn "Формат: IP-IP (например: 192.168.1.200-192.168.1.200)"
    /snap/bin/microk8s enable metallb
}

# Установка Helm чарта
install_helm_chart() {
    log_info "Выберите способ установки Helm чарта:"
    echo "1) Клонировать репозиторий и установить локально"
    echo "2) Установить из упакованного файла (если доступен)"
    echo "3) Пропустить установку чарта"
    
    read -p "Ваш выбор (1-3): " choice
    
    case $choice in
        1)
            install_from_git
            ;;
        2)
            install_from_package
            ;;
        3)
            log_info "Установка чарта пропущена"
            ;;
        *)
            log_error "Неверный выбор"
            exit 1
            ;;
    esac
}

# Установка из Git репозитория
install_from_git() {
    log_info "Клонирование репозитория..."
    
    # Проверка наличия git
    if ! command -v git &> /dev/null; then
        log_info "Установка git..."
        dnf install -y git
    fi
    
    # Создание временной директории
    TEMP_DIR=$(mktemp -d)
    cd $TEMP_DIR
    
    git clone https://github.com/SiwaNetwork/Grafanamon.git || {
        log_error "Не удалось клонировать репозиторий"
        exit 1
    }
    
    cd Grafanamon
    git checkout cursor/helm-d208 || {
        log_error "Не удалось переключиться на ветку cursor/helm-d208"
        exit 1
    }
    
    if [ -d "shiwatime-helm-chart" ]; then
        cd shiwatime-helm-chart
        log_info "Установка Helm чарта..."
        /snap/bin/microk8s helm3 install shiwatime . --namespace shiwatime --create-namespace || {
            log_error "Не удалось установить Helm чарт"
            exit 1
        }
        log_info "Helm чарт успешно установлен!"
    else
        log_error "Директория shiwatime-helm-chart не найдена"
        exit 1
    fi
    
    # Очистка
    cd /
    rm -rf $TEMP_DIR
}

# Установка из упакованного файла
install_from_package() {
    read -p "Введите URL упакованного .tgz файла: " chart_url
    
    log_info "Установка Helm чарта из $chart_url..."
    /snap/bin/microk8s helm3 install shiwatime $chart_url --namespace shiwatime --create-namespace || {
        log_error "Не удалось установить Helm чарт"
        exit 1
    }
    log_info "Helm чарт успешно установлен!"
}

# Проверка установки
check_installation() {
    log_info "Проверка установки..."
    
    echo -e "\n${GREEN}Статус подов:${NC}"
    /snap/bin/microk8s kubectl get pods -n shiwatime
    
    echo -e "\n${GREEN}Статус сервисов:${NC}"
    /snap/bin/microk8s kubectl get svc -n shiwatime
    
    echo -e "\n${GREEN}MicroK8s статус:${NC}"
    /snap/bin/microk8s status
}

# Создание алиасов
create_aliases() {
    log_info "Создание алиасов для удобства использования..."
    
    BASHRC="/home/$SUDO_USER/.bashrc"
    
    if [ -f "$BASHRC" ]; then
        # Проверка, не добавлены ли уже алиасы
        if ! grep -q "alias kubectl=" "$BASHRC"; then
            echo "" >> "$BASHRC"
            echo "# MicroK8s aliases" >> "$BASHRC"
            echo "alias kubectl='sudo /snap/bin/microk8s kubectl'" >> "$BASHRC"
            echo "alias helm='sudo /snap/bin/microk8s helm3'" >> "$BASHRC"
            log_info "Алиасы добавлены в $BASHRC"
        else
            log_warn "Алиасы уже существуют"
        fi
    fi
}

# Вывод инструкций после установки
print_post_install() {
    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}Установка завершена!${NC}"
    echo -e "${GREEN}========================================${NC}\n"
    
    echo "Полезные команды:"
    echo "- Проверить поды: sudo /snap/bin/microk8s kubectl get pods -n shiwatime"
    echo "- Проверить логи: sudo /snap/bin/microk8s kubectl logs -n shiwatime <pod-name>"
    echo "- Обновить чарт: sudo /snap/bin/microk8s helm3 upgrade shiwatime <path-to-chart> -n shiwatime"
    echo "- Удалить чарт: sudo /snap/bin/microk8s helm3 uninstall shiwatime -n shiwatime"
    
    echo -e "\n${YELLOW}Примечание:${NC} Для использования алиасов kubectl и helm, выполните:"
    echo "source ~/.bashrc"
    
    echo -e "\n${YELLOW}Важно:${NC} Возможно, потребуется перелогиниться для применения изменений группы microk8s"
}

# Основная функция
main() {
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Установка Shiwatime с MicroK8s и Helm${NC}"
    echo -e "${GREEN}========================================${NC}\n"
    
    check_sudo
    
    # Установка компонентов
    install_snapd
    install_microk8s
    
    # Ожидание готовности MicroK8s
    log_info "Ожидание готовности MicroK8s..."
    /snap/bin/microk8s status --wait-ready
    
    enable_addons
    install_helm_chart
    
    # Дополнительные настройки
    create_aliases
    
    # Проверка
    check_installation
    
    # Инструкции
    print_post_install
}

# Запуск основной функции
main