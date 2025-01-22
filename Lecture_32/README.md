
# Проект автоматизації з використанням Ansible

## Опис проекту

Цей проєкт демонструє використання Ansible для автоматизації різних завдань, включаючи:
1. Налаштування інфраструктури за допомогою Vagrant.
2. Розгортання PostgreSQL на AWS з використанням Ansible.
3. Захист конфіденційних даних через Ansible Vault.

---

## Структура проєкту

```
├── ansible.cfg
├── aws_ec2.yml
├── dynamic_playbook.yml
├── inventory.ini
├── playbook-pgsql.yml
├── playbook.yml
├── README.md
├── roles
│   ├── baseline
│   │   ├── defaults
│   │   │   └── main.yml
│   │   ├── files
│   │   ├── handlers
│   │   │   └── main.yml
│   │   ├── meta
│   │   │   └── main.yml
│   │   ├── README.md
│   │   ├── tasks
│   │   │   └── main.yml
│   │   ├── tests
│   │   │   ├── inventory
│   │   │   └── test.yml
│   │   └── vars
│   │       └── main.yml
│   ├── firewall
│   │   ├── tasks
│   │   │   └── main.yml
│   │   └── vars
│   │       └── main.yml
│   ├── nginx
│   │   ├── files
│   │   │   └── index.html
│   │   ├── handlers
│   │   │   └── main.yml
│   │   ├── tasks
│   │   │   └── main.yml
│   │   ├── templates
│   │   │   └── nginx.conf.j2
│   │   └── vars
│   │       └── main.yml
│   └── postgresql
│       ├── defaults
│       │   └── main.yml
│       ├── files
│       ├── handlers
│       │   └── main.yml
│       ├── meta
│       │   └── main.yml
│       ├── README.md
│       ├── tasks
│       │   └── main.yml
│       ├── templates
│       ├── tests
│       │   ├── inventory
│       │   └── test.yml
│       └── vars
│           └── main.yml
├── Vagrantfile
└── vault.yml

```

---

## Основні кроки

### 1. Створення Vagrant-інфраструктури

Файл `Vagrantfile` використовується для створення базового середовища для тестування Ansible. У командному рядку:
```bash
vagrant up
```
Перевірка доступності створених хостів 
![Alt-текст](<1.png>)

### 2. Налаштування Ansible

- Створено `ansible.cfg` для базових конфігурацій Ansible.
- Використовується файл `aws_ec2.yml` для динамічного інвентаря.

### 3. Захист даних через Ansible Vault

Команди для створення та редагування зашифрованого файлу:
```bash
ansible-vault create vault.yml
ansible-vault edit vault.yml
```

### 4. Ролі Ansible

#### 4.1 `baseline`
Роль для налаштування базових компонентів:
- Додавання користувача.
- Встановлення базових пакетів.

#### 4.2 `firewall`
Налаштування `ufw` для захисту серверу.

#### 4.3 `nginx`
Розгортання Nginx:
- Конфігурація через шаблони.
- Додавання `index.html`.

#### 4.4 `postgresql`
Розгортання PostgreSQL на AWS:
- Встановлення PostgreSQL.
- Налаштування пароля через Vault.

---

## Приклади використання

### Запуск базового плейбука для vagrant hosts
```bash
ansible-playbook -i inventory.ini playbook.yml
```
![Alt-текст](<2.png>)

### Запуск dynamic playbook AWS
```bash
ansible-playbook -i aws_ec2.yml dynamic_playbook.yml
```
### Запуск плейбука для AWS з використанням vault
```bash
ansible-playbook -i aws_ec2.yml playbook-pgsql.yml --ask-vault-pass
```
![Alt-текст](<4.png>)

### Результати
- Сервер PostgreSQL розгорнуто на AWS.
- Пароль адміністратора `postgres` зберігається у Vault.

---
![Alt-текст](<5.png>)
## Висновок

Цей проект демонструє інтеграцію Ansible Vault, Vagrant та динамічних інвентарів для автоматизації задач DevOps.
