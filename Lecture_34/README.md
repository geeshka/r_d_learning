
# Налаштування Jenkins для автоматизації збирання та деплою проєкту

## Опис процесу

Цей документ описує кроки для налаштування Jenkins у Docker, створення Freestyle Job, який збиратиме Java-проєкт за допомогою Maven та деплоїтиме артефакт на сервер через SSH.

---

## 1. Підняття Jenkins у Docker,встановлення java в ec2

### Передумови
- Встановлений Docker.

### Кроки
1. Запуск Docker jenkins:
```bash
docker run -d -p 8080:8080 -p 50000:50000 --name jenkins   -v jenkins_home:/var/jenkins_home   -v /var/run/docker.sock:/var/run/docker.sock   jenkins/jenkins:lts
```

2. Зайдіть на [http://localhost:8080](http://localhost:8080) та завершіть ініціалізацію Jenkins, використовуючи початковий пароль із контейнера:

```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```
3. Встановіть java 17
```bash
sudo apt update && sudo apt install openjdk-17-jdk -y
```
---

## 2. Створення Freestyle Job

### 2.1. Кроки для створення
1. Перейдіть в глобальні налаштування "Manasge Jenkins -> System configuration -> System -> Publish over SSH" та налаштуйте ключ, ім'я серверу, ІР адресу та ін.
![Alt-текст](<9.png>)
![Alt-текст](<10.png>)
2. Увійдіть до Jenkins.
3. Натисніть **"Створити новий елемент"**.
4. Оберіть **"Freestyle project"**.

### 2.2. Налаштування
#### **Source Code Management**
- Оберіть `Git`.
- Вкажіть URL репозиторію:

```
https://github.com/geeshka/Lecture_34_jenkins.git
```

- Якщо потрібна автентифікація, додайте відповідні креденшали.

#### **Build Steps**
1. Додайте "Invoke top-level Maven targets".
2. Вкажіть наступне:
   - **Версія Maven**: Default Maven (або інша, попередньо налаштована).
   - **Цілі**: `clean install`.
   - **POM**: `initial/pom.xml`.

#### **Post-build Actions**
1. Додайте "Send build artifacts over SSH".
2. Налаштуйте:
   - **SSH Server**: 
     - Ім'я: `temporary-instance`
     - Hostname: `<IP сервера>`
     - Username: `ubuntu`
     - Path to Key: вкажіть приватний ключ або його вміст.
   - **Source Files**: 
     ```
     initial/target/spring-boot-initial-0.0.1-SNAPSHOT.jar
     ```
   - **Remove prefix**: 
     ```
     initial/target
     ```
   - **Remote directory**:
     ```
     /home/ubuntu/app
     ```  
---

## 3. Результати

### 3.1. Freestyle Job
- Скриншоти конфігурації:
  - Source Code Management
  - Build Steps
  - Post-build Actions
![Alt-текст](<1.png>)
![Alt-текст](<2.png>)
![Alt-текст](<3.png>)
![Alt-текст](<4.png>)
![Alt-текст](<5.png>)
![Alt-текст](<6.png>)


### 3.2. Логи виконання
- Приклад успішного виконання з артефактом на сервері:

```bash
# Підключення до сервера
ssh ubuntu@<IP>

# Перевірка файлів
ls -la /home/ubuntu/app
![Alt-текст](<7.png>)
# Запуск артефакту
java -jar /home/ubuntu/app/spring-boot-initial-0.0.1-SNAPSHOT.jar
```
![Alt-текст](<8.png>)
---

