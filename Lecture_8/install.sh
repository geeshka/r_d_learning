#!/bin/bash

DEFAULT_PACKAGES=("apache2" "mariadb-server" "ufw" "docker")

determine_distro() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
  else
    echo "Невідомий дистрибутив."
    exit 1
  fi
}

update_system() {
  case "$DISTRO" in
    ubuntu|debian)
      sudo apt-get update
      sudo apt-get upgrade -y
      ;;
    fedora)
      sudo dnf update -y
      ;;
    centos|rhel)
      sudo yum update -y
      ;;
    *)
      echo "Невідомий дистрибутив для оновлення."
      exit 1
      ;;
  esac
}

install_docker() {
  case "$DISTRO" in
    ubuntu)
      sudo apt-get remove -y docker docker-engine docker.io containerd runc
      sudo apt-get update
      sudo apt-get install -y ca-certificates curl gnupg lsb-release
      sudo mkdir -m 0755 -p /etc/apt/keyrings
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      sudo apt-get update
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
      ;;
    debian)
      sudo apt-get remove -y docker docker-engine docker.io containerd runc
      sudo apt-get update
      sudo apt-get install -y ca-certificates curl gnupg lsb-release
      sudo mkdir -m 0755 -p /etc/apt/keyrings
      curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      sudo apt-get update
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
      ;;
    fedora)
      sudo dnf -y remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine
      sudo dnf -y install dnf-plugins-core
      sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
      sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
      sudo systemctl start docker
      sudo systemctl enable docker
      ;;
    centos|rhel)
      sudo yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
      sudo yum install -y yum-utils
      sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
      sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
      sudo systemctl start docker
      sudo systemctl enable docker
      ;;
    *)
      echo "Невідомий дистрибутив для установки Docker."
      exit 1
      ;;
  esac
}

install_package() {
  local pkg=$1
  if [[ "$DISTRO" == "centos" || "$DISTRO" == "rhel" ]] && [ "$pkg" == "apache2" ]; then
    pkg="httpd"
  fi
  if [[ "$DISTRO" == "centos" || "$DISTRO" == "rhel" ]] && [ "$pkg" == "ufw" ]; then
    pkg="firewalld"
  fi
  if [ "$pkg" == "docker" ]; then
    install_docker
    return
  fi
  case "$DISTRO" in
    ubuntu|debian)
      if dpkg -l | grep -qw "$pkg"; then
        echo "$pkg вже встановлено, оновлюємо..."
        sudo apt-get install --only-upgrade -y "$pkg"
      else
        sudo apt-get install -y "$pkg"
      fi
      ;;
    fedora)
      if rpm -q "$pkg"; then
        echo "$pkg вже встановлено, оновлюємо..."
        sudo dnf upgrade -y "$pkg"
      else
        sudo dnf install -y "$pkg"
      fi
      ;;
    centos|rhel)
      if rpm -q "$pkg"; then
        echo "$pkg вже встановлено, оновлюємо..."
        sudo yum update -y "$pkg"
      else
        sudo yum install -y "$pkg"
      fi
      ;;
    *)
      echo "Невідомий дистрибутив для встановлення пакетів."
      exit 1
      ;;
  esac
}

setup_firewall() {
  case "$DISTRO" in
    ubuntu|debian)
      sudo ufw enable
      sudo ufw allow 80/tcp      
      sudo ufw allow 443/tcp     
      sudo ufw allow 3306/tcp    
      sudo ufw allow 22/tcp      
      ;;
    fedora|centos|rhel)
      sudo systemctl enable firewalld --now
      sudo firewall-cmd --add-service=http --permanent
      sudo firewall-cmd --add-service=https --permanent
      sudo firewall-cmd --add-service=mysql --permanent
      sudo firewall-cmd --reload
      ;;
    *)
      echo "Невідомий дистрибутив для налаштування firewall."
      exit 1
      ;;
  esac
}

check_installed_packages() {
  for pkg in "$@"; do
    if [[ "$DISTRO" == "centos" || "$DISTRO" == "rhel" ]] && [ "$pkg" == "apache2" ]; then
      pkg="httpd"
    fi
    if [[ "$DISTRO" == "centos" || "$DISTRO" == "rhel" ]] && [ "$pkg" == "ufw" ]; then
      pkg="firewalld"
    fi
    case "$DISTRO" in
      ubuntu|debian)
        if dpkg -l | grep -qw "$pkg"; then
          echo "$pkg встановлено."
        else
          echo "$pkg не встановлено."
        fi
        ;;
      fedora|centos|rhel)
        if rpm -q "$pkg"; then
          echo "$pkg встановлено."
        else
          echo "$pkg не встановлено."
        fi
        ;;
      *)
        echo "Невідомий дистрибутив для перевірки встановлення пакетів."
        exit 1
        ;;
    esac
  done
}

install_default_packages() {
  for pkg in "${DEFAULT_PACKAGES[@]}"; do
    install_package "$pkg"
  done
}

install_additional_packages() {
  for pkg in "$@"; do
    install_package "$pkg"
  done
}


main() {
  determine_distro
  echo "Ви використовуєте дистрибутив: $DISTRO"
  update_system
  install_default_packages

  setup_firewall

  if [ "$#" -gt 0 ]; then
    echo "Встановлюємо додаткові пакети: $@"
    install_additional_packages "$@"
  else
    echo "Додаткові пакети не вказані."
  fi


  echo "Перевіряємо встановлені пакети..."
  check_installed_packages "${DEFAULT_PACKAGES[@]}"

  echo "Усі пакети успішно встановлені."
}

main "$@"
