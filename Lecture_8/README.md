1. За допомогою редактора nano створюємо файл install.sh та даємо права на виконання chmod +x.
2. В скрипті:
 2.1 Вказуємо масив пакетів для встановлення;
 2.2 Прописуємо функцію для визначення дистрибутива;
 2.3 Вказуємо функцію для оновлення системи в залежності від дистрибутива
 2.4 Вказуємо окрему функцію для інсталювання докера;
 2.5 Вказуємо функцію для встановлення інших пакетів в залежності від дистрибутива;
 2.6 Вказуємо функцію для налаштування фаєрволу
 2.7 Пишемо функцію для перевірки встановлення пакетів
 2.8 Основну функцію для встановлення основних пакетів та встановлення додаткових пакетів, переданих як аргументи
 2.9 Основний блок
 2.10 Виклик основної функції.

3. Результати
  3.1 Виведено на екран наш дистрибутив
  ![alt text](<1.png>)
  3.2 Встанолення пакетів та залежностей
  ![alt text](<2.png>)
  3.3 Результат
  ![alt text](<3.png>)