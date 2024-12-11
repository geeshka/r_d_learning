
# 📘 **Проєкт: Розгортання кластера EKS на AWS та розгортання застосунків**

---

## 🛠️ **Опис проєкту**
Цей проєкт присвячений розгортанню кластера EKS (Elastic Kubernetes Service) на AWS за допомогою AWS CLI та Kubernetes. Основною метою є створення та налаштування кластера з двома воркер-нодами, розгортання статичного веб-сайту, використання PersistentVolumeClaim (PVC), створення Job, розгортання тестового застосунку та робота з неймспейсами.

---

## 📋 **Завдання**
1. **Створити кластер EKS**
   - Використати AWS CLI для створення кластера EKS.
   - Кластер має складатися щонайменше з двох воркер-нод (Node Groups) у публічній підмережі.
   - Воркер-ноди мають використовувати EC2-інстанси типу `t3.medium`.
   Для виконання цього завдання необхідно спочатку створити ролі, vpc, subnets, security groups

![Alt-текст](<1.png>)
![Alt-текст](<2.png>)
![Alt-текст](<3.png>)
![Alt-текст](<4.png>)
![Alt-текст](<5.png>)

Маючи id security group, vpc, subnet можемо створити кластер

![Alt-текст](<6.png>)
![Alt-текст](<8.png>)

2. **Налаштувати kubectl для доступу до кластера**
   - Підключити локальний `kubectl` до кластера.

![Alt-текст](<9.png>)

   - Перевірити, що команда `kubectl get nodes` показує воркер-ноди кластера у стані **Ready**.
Та спочатку треба створити node group, приаттачивши певні полісі

![Alt-текст](<10.png>)
![Alt-текст](<11.png>)
![Alt-текст](<12.png>)
![Alt-текст](<13.png>)

3. **Розгорнути статичний веб-сайт**
   - Створити ConfigMap для зберігання файлу `index.html`.
   - Створити Deployment для веб-сайту на основі образу Nginx.
   - Використати Service типу `LoadBalancer`, щоб зробити веб-сайт доступним через публічний IP.

Тут створено такі маніфести: web-configmap.yaml, web-deployment.yaml, web-service.yaml

4. **Створити PersistentVolumeClaim для збереження даних**
   - Використати динамічне створення сховища (StorageClass) для створення PersistentVolumeClaim.
   - Розгорнути Pod, який застосовує цей PVC для збереження даних на EBS-диску.

Тут створено такі маніфести: storage-class.yaml, pvc.yaml, pod-with-pvc.yaml

5. **Запуск завдання за допомогою Job**
   - Створити Job, який виконує просту команду `echo "Hello from EKS!"`.
   - Перевірити, що Job виконується успішно.

![Alt-текст](<14.png>)
![Alt-текст](<15.png>)


Тут створено такі маніфести: job.yaml

6. **Розгорнути тестовий застосунок**
   - Розгорнути застосунок з образу `httpd` (Apache HTTP Server).
   - Використати Deployment для створення двох реплік.
   - Налаштувати Service типу `ClusterIP` для доступу до застосунку всередині кластера.

Тут створено такі маніфести:  test-deployment.yaml, test-service.yaml

7. **Робота з неймспейсами**
   - Створити окремий namespace `dev`.
   - Розгорнути у namespace `dev` застосунок з 5 репліками на основі образу `busybox`, який виконує команду `sleep 3600`.

Тут створено такі маніфести: busybox-dev.yaml

8. **Очистити ресурси**
   - Видалити Deployment, Pod, Service, PVC та інші ресурси після завершення роботи.

![Alt-текст](<16.png>)
---

## 📦 **Виконані завдання**

### **1️⃣ Створення кластера EKS**
- Виконано команду для створення кластера EKS:
  ```bash
  aws eks create-cluster     --name eks-cluster     --role-arn arn:aws:iam::<account_id>:role/eks-role     --resources-vpc-config subnetIds=<subnet-ids>,securityGroupIds=<security-group-id>     --region eu-north-1
  ```

- Перевірено статус кластера:
  ```bash
  aws eks describe-cluster --name eks-cluster --region eu-north-1 --query cluster.status
  ```

- Успішно підключено `kubectl` до кластера:
  ```bash
  aws eks update-kubeconfig --region eu-north-1 --name eks-cluster
  ```

- Перевірено воркер-ноди:
  ```bash
  kubectl get nodes
  ```

---

### **2️⃣ Налаштування воркер-нод**
- Виконано команду для створення Node Group:
  ```bash
  aws eks create-nodegroup     --cluster-name eks-cluster     --nodegroup-name eks-node-group     --subnets <subnet-ids>     --node-role arn:aws:iam::<account_id>:role/eks-role     --scaling-config minSize=1,maxSize=3,desiredSize=2     --disk-size 20     --instance-types t3.medium     --region eu-north-1
  ```

---

### **3️⃣ Розгортання статичного веб-сайту**
- **Створено ConfigMap** для файлу `index.html`.
- **Створено Deployment** для запуску Nginx з двома репліками.
- **Створено Service типу LoadBalancer** для доступу до сайту за публічним IP.

---

### **4️⃣ Використання PersistentVolumeClaim**
- **Створено StorageClass**, **PVC** та **Pod**, який використовує цей PVC.
- Динамічно створено EBS диск і змонтовано його в Pod.

---

### **5️⃣ Запуск завдання за допомогою Job**
- Виконано команду для створення Job, який виконує:
  ```bash
  echo "Hello from EKS!"
  ```

---

### **6️⃣ Розгортання тестового застосунку**
- **Розгорнуто Deployment** для запуску застосунку `httpd` із двома репліками.
- **Створено Service типу ClusterIP** для доступу до застосунку зсередини кластера.

---

### **7️⃣ Робота з неймспейсами**
- **Створено namespace `dev`**:
  ```bash
  kubectl create namespace dev
  ```

- **Розгорнуто Deployment** у namespace `dev`, що запускає 5 реплік контейнера на основі образу `busybox` із командою `sleep 3600`.

---

### **8️⃣ Очищення ресурсів**
- Видалено всі ресурси:
  ```bash
  kubectl delete all --all --all-namespaces
  ```

---

## 📋 **Команди для швидкого доступу**

### 🛠️ **Перевірка статусу кластера**
```bash
aws eks describe-cluster --name eks-cluster --region eu-north-1 --query cluster.status
```

### 🛠️ **Перевірка воркер-нод**
```bash
kubectl get nodes
```

### 🛠️ **Створення namespace**
```bash
kubectl create namespace dev
```

### 🛠️ **Видалення всіх ресурсів**
```bash
kubectl delete all --all --all-namespaces
```
