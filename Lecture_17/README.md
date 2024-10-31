# Лекция 17: Работа с Docker

## Завдання 1
Зайдемо на официальный сайт Docker и установим его для нашего дистрибутива: [Docker Installation Guide for Ubuntu](https://docs.docker.com/engine/install/ubuntu/).

## Завдання 2
Создадим файлы:

- `.env`
- `index.html`
- `docker-compose.yml`

Создадим сеть `appnet` с помощью команды:

```bash
$ docker network create appnet
```

## Завдання 3
Запустим Docker Compose в фоновом режиме и проверим результат:

```bash
$ docker-compose up -d
Starting postgres-container ... done
Starting nginx-container    ... done
Starting redis-container    ... done
```

Посмотрим запущенные контейнеры:

```bash
$ docker ps
CONTAINER ID   IMAGE             COMMAND                  CREATED         STATUS         PORTS                                       NAMES
3f5085233519   redis:latest      "docker-entrypoint.s..."   2 minutes ago   Up 3 seconds   0.0.0.0:6379->6379/tcp, :::6379->6379/tcp   redis-container
97b56b44985c   postgres:latest   "docker-entrypoint.s..."   2 minutes ago   Up 3 seconds   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp   postgres-container
3a15a1891fd2   nginx:latest      "/docker-entrypoint...."   2 minutes ago   Up 3 seconds   0.0.0.0:8080->80/tcp, [::]:8080->80/tcp     nginx-container
```

Проверим доступность нашего приложения:

```bash
$ curl -i http://localhost:8080
HTTP/1.1 200 OK
Server: nginx/1.27.2
Date: Tue, 29 Oct 2024 09:52:52 GMT
Content-Type: text/html
Content-Length: 130
Last-Modified: Tue, 29 Oct 2024 09:52:05 GMT
Connection: keep-alive
ETag: "6720b045-82"
Accept-Ranges: bytes

<!DOCTYPE html>
<html>
<head>
    <title>My Docker App</title>
</head>
<body>
    <h1>OK!</h1>
</body>
</html>
```

## Завдання 4
### Проверка сетей и томов, проверка доступа к БД

Проверим созданные сети:

```bash
$ docker network ls
NETWORK ID     NAME                  DRIVER    SCOPE
dedf1b8e52bb   appnet                bridge    local
ee813ffe3fcb   bridge                bridge    local
b16d36e797bf   host                  host      local
e81dd3d3fd9b   ii_learning_default   bridge    local
44968fbae5cd   lecture_17_appnet     bridge    local
a3ecd2391178   meshcuda_default      bridge    local
4f27d6e08a6f   meshcuda_py_default   bridge    local
f60e56c34be1   none                  null      local
```

Проверим созданные тома:

```bash
$ docker volume ls
DRIVER    VOLUME NAME
local     0c4ad7db10c90fcf294b39784bfc7d12977aaa42b34b8f2275aed1428b83c17f
local     lecture_17_db-data
local     lecture_17_web-data
```

Проверим состояние контейнеров:

```bash
$ docker-compose ps
       Name                     Command               State                    Ports                  
------------------------------------------------------------------------------------------------------
nginx-container      /docker-entrypoint.sh ngin ...   Up      0.0.0.0:8080->80/tcp,:::8080->80/tcp    
postgres-container   docker-entrypoint.sh postgres    Up      0.0.0.0:5432->5432/tcp,:::5432->5432/tcp
redis-container      docker-entrypoint.sh redis ...   Up      0.0.0.0:6379->6379/tcp,:::6379->6379/tcp
```

Подключаемся к базе данных PostgreSQL:

```bash
$ docker exec -it 97b56b44985c psql -U postgres -d postgres
psql (17.0 (Debian 17.0-1.pgdg120+1))
Type "help" for help.
postgres=#
```

## Завдання 5: Масштабирование
Попробуем масштабировать сервис `nginx` до 3 экземпляров с помощью команды:

```bash
$ docker-compose up -d --scale nginx=3 --force-recreate
Recreating postgres-container ...
WARNING: The "nginx" service is using the custom container name "nginx-container". Docker requires each container to have a unique name. Remove the custom name to scale the service.
Recreating redis-container    ...
WARNING: The "nginx" service specifies a port on the host. If multiple containers for this service are created on a single host, the port will clash.
Recreating nginx-container    ...

ERROR: for postgres-container  'ContainerConfig'
ERROR: for redis-container  'ContainerConfig'
ERROR: for nginx-container  'ContainerConfig'
Traceback (most recent call last):
  ...
KeyError: 'ContainerConfig'
[783757] Failed to execute script docker-compose
```

### Решение проблемы
Для исправления ошибки необходимо:
- Закомментировать строки `container_name` и настройки проброса портов для `nginx`, чтобы не возникало конфликтов.
- Выполнить команду `docker-compose down` для пересоздания контейнеров.

```bash
$ nano docker-compose.yml
$ docker-compose down
Removing 3f5085233519_redis-container    ... done
Removing 97b56b44985c_postgres-container ... done
Removing 3a15a1891fd2_nginx-container    ... done
Removing network lecture_17_appnet
```

Теперь снова запускаем `docker-compose` с масштабированием:

```bash
$ docker-compose up -d --scale nginx=3
Creating network "lecture_17_appnet" with the default driver
Creating postgres-container ... done
Creating lecture_17_nginx_1 ... done
Creating lecture_17_nginx_2 ... done
Creating lecture_17_nginx_3 ... done
Creating redis-container    ... done
```

Проверяем состояние контейнеров:

```bash
$ docker-compose ps
       Name                     Command               State                    Ports                  
------------------------------------------------------------------------------------------------------
lecture_17_nginx_1   /docker-entrypoint.sh ngin ...   Up      80/tcp                                  
lecture_17_nginx_2   /docker-entrypoint.sh ngin ...   Up      80/tcp                                  
lecture_17_nginx_3   /docker-entrypoint.sh ngin ...   Up      80/tcp                                  
postgres-container   docker-entrypoint.sh postgres    Up      0.0.0.0:5432->5432/tcp,:::5432->5432/tcp
redis-container      docker-entrypoint.sh redis ...   Up      0.0.0.0:6379->6379/tcp,:::6379->6379/tcp
```

Теперь всё корректно создано и работает.

