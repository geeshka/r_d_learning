1. Завдання 1
Заходимо на офсайт докера та встановлюємо для нашого дистрибутиву https://docs.docker.com/engine/install/ubuntu/
2. Завдання 2 
Створюємо файли .env, index.html та docker-compose.yml
Створюємо мережу appnet за допомогою команди docker network create appnet
3. Завдання 3 
Запускаємо наш докер-копмоз в фоновому режимі та дивимось результат
geeshka@geeshka-desktop:~/r_d_learning/Lecture_17$ docker-compose up -d
Starting postgres-container ... done
Starting nginx-container    ... done
Starting redis-container    ... done
geeshka@geeshka-desktop:~/r_d_learning/Lecture_17$ docker ps
CONTAINER ID   IMAGE             COMMAND                  CREATED         STATUS         PORTS                                       NAMES
3f5085233519   redis:latest      "docker-entrypoint.s…"   2 minutes ago   Up 3 seconds   0.0.0.0:6379->6379/tcp, :::6379->6379/tcp   redis-container
97b56b44985c   postgres:latest   "docker-entrypoint.s…"   2 minutes ago   Up 3 seconds   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp   postgres-container
3a15a1891fd2   nginx:latest      "/docker-entrypoint.…"   2 minutes ago   Up 3 seconds   0.0.0.0:8080->80/tcp, [::]:8080->80/tcp     nginx-container
geeshka@geeshka-desktop:~/r_d_learning/Lecture_17$ curl -i http://localhost:8080
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

4. Завдання 4
Перевірка мережей і томів, перевірка доступу до БД
geeshka@geeshka-desktop:~/r_d_learning/Lecture_17$ docker network ls
NETWORK ID     NAME                  DRIVER    SCOPE
dedf1b8e52bb   appnet                bridge    local
ee813ffe3fcb   bridge                bridge    local
b16d36e797bf   host                  host      local
e81dd3d3fd9b   ii_learning_default   bridge    local
44968fbae5cd   lecture_17_appnet     bridge    local
a3ecd2391178   meshcuda_default      bridge    local
4f27d6e08a6f   meshcuda_py_default   bridge    local
f60e56c34be1   none                  null      local
geeshka@geeshka-desktop:~/r_d_learning/Lecture_17$ docker volume ls
DRIVER    VOLUME NAME
local     0c4ad7db10c90fcf294b39784bfc7d12977aaa42b34b8f2275aed1428b83c17f
local     lecture_17_db-data
local     lecture_17_web-data
geeshka@geeshka-desktop:~/r_d_learning/Lecture_17$ docker-compose ps
       Name                     Command               State                    Ports                  
------------------------------------------------------------------------------------------------------
nginx-container      /docker-entrypoint.sh ngin ...   Up      0.0.0.0:8080->80/tcp,:::8080->80/tcp    
postgres-container   docker-entrypoint.sh postgres    Up      0.0.0.0:5432->5432/tcp,:::5432->5432/tcp
redis-container      docker-entrypoint.sh redis ...   Up      0.0.0.0:6379->6379/tcp,:::6379->6379/tcp
geeshka@geeshka-desktop:~/r_d_learning/Lecture_17$ docker exec -it 97b56b44985c psql -U postgres -d postgres
psql (17.0 (Debian 17.0-1.pgdg120+1))
Type "help" for help.
postgres=# 


5. Масштабування
Спробуємо масштабувати командою docker-compose up -d --scale nginx=3 --force-recreate, та через специфічні налаштування конфігу docker-compose сервіса nginx отримуємо помилку
geeshka@geeshka-desktop:~/r_d_learning/Lecture_17$ docker-compose up -d --scale nginx=3 --force-recreate
Recreating postgres-container ... 
WARNING: The "nginx" service is using the custom container name "nginx-container". Docker requires each container to have a unique name. Remove the custom name to scale the service.
Recreating redis-container    ... 
WARNING: The "nginx" service specifies a port on the host. If multiple containers for this service are created on a single host, the port will clash.
Recreating nginx-container    ... 

ERROR: for postgres-container  'ContainerConfig'

ERROR: for redis-container  'ContainerConfig'

ERROR: for nginx-container  'ContainerConfig'

ERROR: for postgres  'ContainerConfig'

ERROR: for redis  'ContainerConfig'

ERROR: for nginx  'ContainerConfig'
Traceback (most recent call last):
  File "docker-compose", line 3, in <module>
  File "compose/cli/main.py", line 81, in main
  File "compose/cli/main.py", line 203, in perform_command
  File "compose/metrics/decorator.py", line 18, in wrapper
  File "compose/cli/main.py", line 1186, in up
  File "compose/cli/main.py", line 1182, in up
  File "compose/project.py", line 702, in up
  File "compose/parallel.py", line 108, in parallel_execute
  File "compose/parallel.py", line 206, in producer
  File "compose/project.py", line 688, in do
  File "compose/service.py", line 581, in execute_convergence_plan
  File "compose/service.py", line 503, in _execute_convergence_recreate
  File "compose/parallel.py", line 108, in parallel_execute
  File "compose/parallel.py", line 206, in producer
  File "compose/service.py", line 496, in recreate
  File "compose/service.py", line 615, in recreate_container
  File "compose/service.py", line 334, in create_container
  File "compose/service.py", line 922, in _get_container_create_options
  File "compose/service.py", line 962, in _build_container_volume_options
  File "compose/service.py", line 1549, in merge_volume_bindings
  File "compose/service.py", line 1579, in get_container_data_volumes
KeyError: 'ContainerConfig'
[783757] Failed to execute script docker-compose

Виправити можна, закоментувавши рядки container_name та рядок з пробросом портів, щоб не було конфліктів, та зробивши docker-compose down для перестворення контейнерів:

geeshka@geeshka-desktop:~/r_d_learning/Lecture_17$ nano docker-compose.yml 
geeshka@geeshka-desktop:~/r_d_learning/Lecture_17$ docker-compose down
Removing 3f5085233519_redis-container    ... done
Removing 97b56b44985c_postgres-container ... done
Removing 3a15a1891fd2_nginx-container    ... done
Removing network lecture_17_appnet
geeshka@geeshka-desktop:~/r_d_learning/Lecture_17$ docker-compose up -d --scale nginx=3
Creating network "lecture_17_appnet" with the default driver
Creating postgres-container ... done
Creating lecture_17_nginx_1 ... done
Creating lecture_17_nginx_2 ... done
Creating lecture_17_nginx_3 ... done
Creating redis-container    ... done
geeshka@geeshka-desktop:~/r_d_learning/Lecture_17$ docker-compose ps
       Name                     Command               State                    Ports                  
------------------------------------------------------------------------------------------------------
lecture_17_nginx_1   /docker-entrypoint.sh ngin ...   Up      80/tcp                                  
lecture_17_nginx_2   /docker-entrypoint.sh ngin ...   Up      80/tcp                                  
lecture_17_nginx_3   /docker-entrypoint.sh ngin ...   Up      80/tcp                                  
postgres-container   docker-entrypoint.sh postgres    Up      0.0.0.0:5432->5432/tcp,:::5432->5432/tcp
redis-container      docker-entrypoint.sh redis ...   Up      0.0.0.0:6379->6379/tcp,:::6379->6379/tcp

Тепер все корекно створено та працює.
