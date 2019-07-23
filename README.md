# OTUS_LinuxAdministration
Выполненные задания по курсу "Администрирование Linux"

### Содержание
1. [Занятие 1. С  чего начинается Linux](#lesson_01)
2. [Занятие 2. Дисковая подсистема](#lesson_02)
3. [Занятие 3. Файловые системы и LVM](#lesson_03)

### Занятие 1. С  чего начинается Linux <a name="lesson_01"></a>
**Домашнее задание**. Делаем собственную сборку ядра.
- Взять любую версию ядра с kernel.org.
- Подложить файл конфигурации ядра.
- Собрать ядро (попутно доставляя необходимые пакеты).
- Прислать результирующий файл конфигурации.
- Прислать список доустановленных пакетов (взять его можно из /var/log/yum.log).

### Занятие 2. Дисковая подсистема <a name="lesson_02"></a>
**Домашнее задание**. Работа с mdadm.
> добавить в Vagrantfile еще дисков
> сломать/починить raid
> собрать R0/R5/R10 - на выбор
> создать на рейде GPT раздел и 5 партиций
>
> в качестве проверки принимаются - измененный Vagrantfile, скрипт для создания рейда
>
> * доп. задание - Vagrantfile, который сразу собирает систему с подключенным рейдом
>
> ** перенесети работающую систему с одним диском на RAID 1. Даунтайм на загрузку с нового диска предполагается. В качестве > проверики принимается вывод команды lsblk до и после и описание хода решения (можно воспользовать утилитой Script).
> Критерии оценки: - 4 принято - сдан Vagrantfile и скрипт для сборки, который можно запустить на поднятом образе
> - 5 сделано доп задание

### Занятие 3. Файловые системы и LVM <a name="lesson_03"></a>
