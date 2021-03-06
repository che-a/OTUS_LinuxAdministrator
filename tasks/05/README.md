## Занятие 5. Управление процессами

### Содержание
1. [Описание занятия](#description)  
2. [Домашнее задание](#homework)  
3. [Выполнение](#exec)  
    - [Реализация ps ax](#psax)  
       — [Краткие сведения](#psax_short)  
       — [Ход выполнения](#psax_exec)  

## 1. Описание занятия <a name="description"></a>
### Цели
- Рассмотрим, что такое процесс, его атрибуты, жизненный цикл процесса.  
- Чем потоки отличаются от процессов.  
- Узнаем как мониторить процессы, в каком они состоянии, понимать чем они сейчас заняты.  
- Рассмотрим команды `ps`, `top`, подсистему `/proc`, а также команды `gdb`, `strace`, `ltrace`.  
- Научимся менять приоритеты с мощью команд `nice`,  `ionice` .
- Научимся посылать различные сигналы процессам.  

### Краткое содержание    
- Процесс и его атрибуты.  
- Жизнь процессов.  
- Процессы и потоки.  
- Получение информации о процессе.  
- Управление процессом.

### Результаты  
После занятия участник сможет применять вышеуказанные команды в своей работе и получать больше информации и, следовательно,
больше контролировать процессы, работающие в системе.

## 2. Домашнее задание  <a name="homework"></a>
### Постановка задачи  
В результате ДЗ вы разберетесь, что находится в файловой системе `/proc` и закрепите навыки работы с `bash`. Зачастую, например, в контейнерах, у вас нет кучи удобных утилит предоставляющих информацию о процессах, ip адресах  и т.д., и есть только один инструмент `bash` и `/proc`.
Задания на выбор:
1) Написать свою реализацию `ps ax`, используя анализ `/proc`. Результат ДЗ -- рабочий скрипт, который можно запустить.  
2) Написать свою реализацию `lsof`. Результат ДЗ -- рабочий скрипт, который можно запустить.  
3) Дописать обработчики сигналов в прилагаемом скрипте, оттестировать, приложить сам скрипт, инструкции по использованию. Результат ДЗ -- рабочий скрипт, который можно запустить + инструкция по использованию и лог консоли.  
4) Реализовать 2 конкурирующих процесса по IO. пробовать запустить с разными `ionice`. Результат ДЗ -- скрипт запускающий 2 процесса с разными `ionice`, замеряющий время выполнения и лог консоли.  
5) Реализовать 2 конкурирующих процесса по CPU. пробовать запустить с разными `nice`. Результат ДЗ -- скрипт запускающий 2 процесса с разными `nice` и замеряющий время выполнения и лог консоли.

### Критерии оценки  
 5 баллов - принято - любой скрипт,  
+1 балл - больше одного скрипта,  
+2 балла все скрипты.  

## 3. Выполнение <a name="exec"></a>  
### 3.1. Реализация ps ax <a name="psax"></a>  

#### Краткие сведения <a name="psax_short"></a>  
`Процесс` — это работающая программа. Каждому процессу в системе присвоен числовой идентификатор процесса (`PID`).  

Чтобы быстро получить перечень работающих процессов, необходимо выполнить команду `ps`.  

|  Команда  | Описание |
|:---------------------|:---------|
| `ps x`    | Показать все процессы, запущенные вами |
| `ps ax`   | Показать все процессы системы, а не только те, владельцем которых являетесь вы |
| `ps u`    | Включить детализированную информацию о процессах |
| `ps w`    | Показать полные названия команд, а не только те, что помещаются в одной строке |
| `ps u $$` | Показать информацию о текущем процессе оболочки |



<details>
    <summary>Пример выполнения команды ps ax:</summary>    

```console
      PID TTY      STAT   TIME COMMAND
    1 ?        Ss     0:01 /usr/lib/systemd/systemd --switched-root --system --deserialize 21
    2 ?        S      0:00 [kthreadd]
    3 ?        S      0:00 [ksoftirqd/0]
    4 ?        S      0:00 [kworker/0:0]
    5 ?        S<     0:00 [kworker/0:0H]
    6 ?        S      0:00 [kworker/u8:0]
    7 ?        S      0:00 [migration/0]
    8 ?        S      0:00 [rcu_bh]
    9 ?        S      0:00 [rcu_sched]
   10 ?        S<     0:00 [lru-add-drain]
   11 ?        S      0:00 [watchdog/0]
   12 ?        S      0:00 [watchdog/1]
   13 ?        S      0:00 [migration/1]
   14 ?        S      0:00 [ksoftirqd/1]
   15 ?        S      0:00 [kworker/1:0]
   16 ?        S<     0:00 [kworker/1:0H]
   17 ?        S      0:00 [watchdog/2]
   18 ?        S      0:00 [migration/2]
   19 ?        S      0:00 [ksoftirqd/2]
   20 ?        S      0:00 [kworker/2:0]
   21 ?        S<     0:00 [kworker/2:0H]
   22 ?        S      0:00 [watchdog/3]
   23 ?        S      0:00 [migration/3]
   24 ?        S      0:00 [ksoftirqd/3]
   25 ?        R      0:00 [kworker/3:0]
   26 ?        S<     0:00 [kworker/3:0H]
   28 ?        S      0:00 [kdevtmpfs]
   29 ?        S<     0:00 [netns]
   30 ?        S      0:00 [khungtaskd]
   31 ?        S<     0:00 [writeback]
   32 ?        S<     0:00 [kintegrityd]
   33 ?        S<     0:00 [bioset]
   34 ?        S<     0:00 [bioset]
   35 ?        S<     0:00 [bioset]
   36 ?        S<     0:00 [kblockd]
   37 ?        S<     0:00 [md]
   38 ?        S<     0:00 [edac-poller]
   39 ?        S<     0:00 [watchdogd]
   40 ?        S      0:00 [kworker/0:1]
   41 ?        S      0:00 [kworker/u8:1]
   48 ?        S      0:00 [kswapd0]
   49 ?        SN     0:00 [ksmd]
   50 ?        SN     0:00 [khugepaged]
   51 ?        S<     0:00 [crypto]
   59 ?        S<     0:00 [kthrotld]
   60 ?        S<     0:00 [kmpath_rdacd]
   61 ?        S<     0:00 [kaluad]
   62 ?        S<     0:00 [kpsmoused]
   63 ?        S<     0:00 [ipv6_addrconf]
   64 ?        S      0:00 [kworker/0:2]
   77 ?        S<     0:00 [deferwq]
   78 ?        S      0:00 [kworker/1:1]
  108 ?        S      0:00 [kauditd]
  110 ?        S      0:00 [kworker/3:1]
  171 ?        S      0:00 [kworker/1:2]
  588 ?        S<     0:00 [ata_sff]
  607 ?        S      0:00 [scsi_eh_0]
  611 ?        S<     0:00 [scsi_tmf_0]
  619 ?        S      0:00 [scsi_eh_1]
  621 ?        S<     0:00 [scsi_tmf_1]
  698 ?        S      0:00 [kworker/u8:2]
 1038 ?        S      0:00 [kworker/2:1]
 1051 ?        S<     0:00 [bioset]
 1058 ?        S<     0:00 [xfsalloc]
 1059 ?        S<     0:00 [xfs_mru_cache]
 1063 ?        S<     0:00 [xfs-buf/sda1]
 1065 ?        S<     0:00 [xfs-data/sda1]
 1066 ?        S<     0:00 [xfs-conv/sda1]
 1067 ?        S<     0:00 [xfs-cil/sda1]
 1069 ?        S<     0:00 [xfs-reclaim/sda]
 1070 ?        S<     0:00 [xfs-log/sda1]
 1071 ?        S<     0:00 [xfs-eofblocks/s]
 1074 ?        S      0:00 [xfsaild/sda1]
 1077 ?        S<     0:00 [kworker/0:1H]
 1078 ?        S<     0:00 [kworker/2:1H]
 1131 ?        Ss     0:00 /usr/lib/systemd/systemd-journald
 1142 ?        S      0:00 [kworker/3:2]
 1166 ?        Ss     0:00 /usr/lib/systemd/systemd-udevd
 1175 ?        S      0:00 [kworker/2:2]
 1185 ?        S<sl   0:00 /sbin/auditd
 1190 ?        S<     0:00 [rpciod]
 1191 ?        S<     0:00 [xprtiod]
 1337 ?        Ssl    0:00 /usr/lib/polkit-1/polkitd --no-debug
 1341 ?        Ss     0:00 /usr/lib/systemd/systemd-logind
 1342 ?        Ssl    0:00 /usr/bin/dbus-daemon --system --address=systemd: --nofork --nopidfile --systemd-activation
 1385 ?        Ss     0:00 /sbin/rpcbind -w
 1504 ?        S<     0:00 [kworker/3:1H]
 1639 ?        Ss     0:00 /usr/sbin/irqbalance --foreground
 1698 ?        S      0:00 /usr/sbin/chronyd
 1726 ?        Ssl    0:00 /usr/sbin/gssproxy -D
 2044 ?        Ss     0:00 /usr/sbin/crond -n
 2048 tty1     Ss+    0:00 /sbin/agetty --noclear tty1 linux
 2579 ?        Ss     0:00 /usr/sbin/sshd -D -u0
 2581 ?        Ssl    0:00 /usr/bin/python2 -Es /usr/sbin/tuned -l -P
 2582 ?        Ssl    0:00 /usr/sbin/rsyslogd -n
 2603 ?        S<     0:00 [kworker/1:1H]
 2839 ?        Ss     0:00 /usr/libexec/postfix/master -w
 2842 ?        S      0:00 pickup -l -t unix -u
 2843 ?        S      0:00 qmgr -l -t unix -u
 3883 ?        Ssl    0:00 /usr/sbin/NetworkManager --no-daemon
 3908 ?        S      0:00 /sbin/dhclient -d -q -sf /usr/libexec/nm-dhcp-helper -pf /var/run/dhclient-eth0.pid -lf /var/lib/NetworkManager/dhclient-5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03-eth0.lease -cf /var/lib/Ne
 4442 ?        Ss     0:00 sshd: vagrant [priv]
 4445 ?        S      0:00 sshd: vagrant@pts/1
 4446 pts/1    Ss     0:00 -bash
 4469 pts/1    R+     0:00 ps ax
```    
</details>

`procfs` — специальная файловая система. Позволяет получить доступ к информации из ядра о системных процессах. Необходима для выполнения таких команд как `ps`, `w`, `top`. Обычно её монтируют на `/proc`. `procfs` создаёт двухуровневое представление пространств процессов. На верхнем уровне процессы представляют собой каталоги, именованные в соответствии с их `pid`. Также на верхнем уровне располагается ссылка на каталог, соответствующую процессу, выполняющему запрос; она может иметь различное имя в различных ОС (curproc во FreeBSD, self в Linux).

`ps` — программа, выводящая отчёт о работающих процессах.  
Опции:  
`-a` : связанные с конкретным терминалом, кроме главных системных процессов сеанса, часто используемая опция;  
`x` : процессы, отсоединённые от терминала.

Столбцы:  
`PID` — идентификатор процесса;  
`TTY` — терминал, с которым связан данный процесс;  
`STAT` — состояние, в котором на данный момент находится процесс;  
`TIME` — процессорное время, занятое этим процессом;  
`CMD` — команда, запустившая данный процесс «с некоторыми опциями выводит и каталог, откуда процесс был запущен»;  


#### Ход выполнения <a name="psax_exec"></a>  

Сценарий [ps.sh](https://github.com/che-a/OTUS_LinuxAdministrator/blob/master/tasks/05/ps.sh) практически полностью (кроме времени выполнения) повторяет работу команды `ps ax`. Для демонстрации работы сценария [ps.sh](https://github.com/che-a/OTUS_LinuxAdministrator/blob/master/tasks/05/ps.sh) необходимо развернуть тестовое окружение из [Vagrantfile](https://github.com/che-a/OTUS_LinuxAdministrator/blob/master/tasks/05/Vagrantfile) и выполнить команду:
```bash
./ps.sh ax
```
Используя `tmux` можно наглядно сравнить результаты работы сценария [ps.sh](https://github.com/che-a/OTUS_LinuxAdministrator/blob/master/tasks/05/ps.sh) и команды `ps ax`, что показано ниже.

<details>
    <summary>Сравнение работы сценария ps.sh и команды ps ax.</summary>

```console
[vagrant@centos7 ~]$ ./ps.sh ax                                                                 [39/1581]│[vagrant@centos7 ~]$ ps ax                                                                       [39/507]
  PID TTY      STAT   TIME COMMAND                                                                       │  PID TTY      STAT   TIME COMMAND                                                                      
    1 ?        S      0:01 /usr/lib/systemd/systemd --switched-root --system --deserial                  │    1 ?        Ss     0:01 /usr/lib/systemd/systemd --switched-root --system --deserialize 21           
    2 ?        S      0:00 [kthreadd]                                                                    │    2 ?        S      0:00 [kthreadd]                                                                   
    3 ?        S      0:00 [ksoftirqd/0]                                                                 │    3 ?        S      0:00 [ksoftirqd/0]                                                                
    4 ?        S      0:00 [kworker/0:0]                                                                 │    4 ?        S      0:00 [kworker/0:0]                                                                
    5 ?        S<     0:00 [kworker/0:0H]                                                                │    5 ?        S<     0:00 [kworker/0:0H]                                                               
    6 ?        S      0:00 [kworker/u4:0]                                                                │    6 ?        S      0:00 [kworker/u4:0]                                                               
    7 ?        S      0:00 [migration/0]                                                                 │    7 ?        S      0:00 [migration/0]                                                                
    8 ?        S      0:00 [rcu_bh]                                                                      │    8 ?        S      0:00 [rcu_bh]                                                                     
    9 ?        R      0:00 [rcu_sched]                                                                   │    9 ?        S      0:00 [rcu_sched]                                                                  
   10 ?        S<     0:00 [lru-add-drain]                                                               │   10 ?        S<     0:00 [lru-add-drain]                                                              
   11 ?        S      0:00 [watchdog/0]                                                                  │   11 ?        S      0:00 [watchdog/0]                                                                 
   12 ?        S      0:00 [watchdog/1]                                                                  │   12 ?        S      0:00 [watchdog/1]                                                                 
   13 ?        S      0:00 [migration/1]                                                                 │   13 ?        S      0:00 [migration/1]                                                                
   14 ?        S      0:00 [ksoftirqd/1]                                                                 │   14 ?        S      0:00 [ksoftirqd/1]                                                                
   15 ?        S      0:00 [kworker/1:0]                                                                 │   15 ?        S      0:00 [kworker/1:0]                                                                
   16 ?        S<     0:00 [kworker/1:0H]                                                                │   16 ?        S<     0:00 [kworker/1:0H]                                                               
   18 ?        S      0:00 [kdevtmpfs]                                                                   │   18 ?        S      0:00 [kdevtmpfs]                                                                  
   19 ?        S<     0:00 [netns]                                                                       │   19 ?        S<     0:00 [netns]                                                                      
   20 ?        S      0:00 [khungtaskd]                                                                  │   20 ?        S      0:00 [khungtaskd]                                                                 
   21 ?        S<     0:00 [writeback]                                                                   │   21 ?        S<     0:00 [writeback]                                                                  
   22 ?        S<     0:00 [kintegrityd]                                                                 │   22 ?        S<     0:00 [kintegrityd]                                                                
   23 ?        S<     0:00 [bioset]                                                                      │   23 ?        S<     0:00 [bioset]                                                                     
   24 ?        S<     0:00 [bioset]                                                                      │   24 ?        S<     0:00 [bioset]                                                                     
   25 ?        S<     0:00 [bioset]                                                                      │   25 ?        S<     0:00 [bioset]                                                                     
   26 ?        S<     0:00 [kblockd]                                                                     │   26 ?        S<     0:00 [kblockd]                                                                    
   27 ?        S<     0:00 [md]                                                                          │   27 ?        S<     0:00 [md]                                                                         
   28 ?        S<     0:00 [edac-poller]                                                                 │   28 ?        S<     0:00 [edac-poller]                                                                
   29 ?        S<     0:00 [watchdogd]                                                                   │   29 ?        S<     0:00 [watchdogd]                                                                  
   30 ?        S      0:00 [kworker/0:1]                                                                 │   30 ?        S      0:00 [kworker/0:1]                                                                
   31 ?        S      0:00 [kworker/u4:1]                                                                │   31 ?        S      0:00 [kworker/u4:1]                                                               
   38 ?        S      0:00 [kswapd0]                                                                     │   38 ?        S      0:00 [kswapd0]                                                                    
   39 ?        SN     0:00 [ksmd]                                                                        │   39 ?        SN     0:00 [ksmd]                                                                       
   40 ?        SN     0:00 [khugepaged]                                                                  │   40 ?        SN     0:00 [khugepaged]                                                                 
   41 ?        S<     0:00 [crypto]                                                                      │   41 ?        S<     0:00 [crypto]                                                                     
   49 ?        S<     0:00 [kthrotld]                                                                    │   49 ?        S<     0:00 [kthrotld]                                                                   
   50 ?        S<     0:00 [kmpath_rdacd]                                                                │   50 ?        S<     0:00 [kmpath_rdacd]                                                               
   51 ?        S<     0:00 [kaluad]                                                                      │   51 ?        S<     0:00 [kaluad]                                                                     
   52 ?        S<     0:00 [kpsmoused]                                                                   │   52 ?        S<     0:00 [kpsmoused]                                                                  
   53 ?        S      0:00 [kworker/0:2]                                                                 │   53 ?        S      0:00 [kworker/0:2]
   54 ?        S<     0:00 [ipv6_addrconf]                                                               │   54 ?        S<     0:00 [ipv6_addrconf]                                                              
   55 ?        S      0:00 [kworker/1:1]                                                                 │   55 ?        S      0:00 [kworker/1:1]                                                                
   68 ?        S<     0:00 [deferwq]                                                                     │   68 ?        S<     0:00 [deferwq]                                                                    
   97 ?        S      0:00 [kauditd]                                                                     │   97 ?        S      0:00 [kauditd]                                                                    
  102 ?        S      0:00 [kworker/0:3]                                                                 │  102 ?        S      0:00 [kworker/0:3]
  541 ?        S<     0:00 [ata_sff]                                                                     │  541 ?        S<     0:00 [ata_sff]
  572 ?        S      0:00 [scsi_eh_0]                                                                   │  572 ?        S      0:00 [scsi_eh_0]                                                                  
  580 ?        S<     0:00 [scsi_tmf_0]                                                                  │  580 ?        S<     0:00 [scsi_tmf_0]                                                                 
  586 ?        S      0:00 [scsi_eh_1]                                                                   │  586 ?        S      0:00 [scsi_eh_1]                                                                  
  594 ?        S<     0:00 [scsi_tmf_1]                                                                  │  594 ?        S<     0:00 [scsi_tmf_1]                                                                 
  604 ?        S      0:00 [kworker/u4:2]                                                                │  604 ?        S      0:00 [kworker/u4:2]                                                               
  611 ?        S      0:00 [kworker/u4:3]                                                                │  611 ?        S      0:00 [kworker/u4:3]                                                               
  979 ?        S      0:00 [kworker/1:2]                                                                 │  979 ?        R      0:00 [kworker/1:2]                                                                
  989 ?        S<     0:00 [bioset]                                                                      │  989 ?        S<     0:00 [bioset]                                                                     
  991 ?        S<     0:00 [xfsalloc]                                                                    │  991 ?        S<     0:00 [xfsalloc]
  992 ?        S<     0:00 [xfs_mru_cache]                                                               │  992 ?        S<     0:00 [xfs_mru_cache]
  998 ?        S<     0:00 [xfs-buf/sda1]                                                                │  998 ?        S<     0:00 [xfs-buf/sda1]
 1001 ?        S<     0:00 [xfs-data/sda1]                                                               │ 1001 ?        S<     0:00 [xfs-data/sda1]
 1007 ?        S<     0:00 [xfs-conv/sda1]                                                               │ 1007 ?        S<     0:00 [xfs-conv/sda1]
 1010 ?        S<     0:00 [xfs-cil/sda1]                                                                │ 1010 ?        S<     0:00 [xfs-cil/sda1]
 1011 ?        S<     0:00 [xfs-reclaim/sda]                                                             │ 1011 ?        S<     0:00 [xfs-reclaim/sda]
 1012 ?        S<     0:00 [xfs-log/sda1]                                                                │ 1012 ?        S<     0:00 [xfs-log/sda1]
 1013 ?        S<     0:00 [xfs-eofblocks/s]                                                             │ 1013 ?        S<     0:00 [xfs-eofblocks/s]
 1014 ?        S      0:00 [xfsaild/sda1]                                                                │ 1014 ?        S      0:00 [xfsaild/sda1]
 1015 ?        S<     0:00 [kworker/0:1H]                                                                │ 1015 ?        S<     0:00 [kworker/0:1H]
 1068 ?        S      0:00 /usr/lib/systemd/systemd-journald                                             │ 1068 ?        Ss     0:00 /usr/lib/systemd/systemd-journald                                            
 1099 ?        S      0:00 /usr/lib/systemd/systemd-udevd                                                │ 1099 ?        Ss     0:00 /usr/lib/systemd/systemd-udevd                                               
 1118 ?        Sl     0:00 /sbin/auditd                                                                  │ 1118 ?        S<sl   0:00 /sbin/auditd
 1124 ?        S<     0:00 [rpciod]                                                                      │ 1124 ?        S<     0:00 [rpciod]
 1125 ?        S<     0:00 [xprtiod]                                                                     │ 1125 ?        S<     0:00 [xprtiod]
 1238 ?        Sl     0:00 /usr/lib/polkit-1/polkitd --no-debug                                          │ 1238 ?        Ssl    0:00 /usr/lib/polkit-1/polkitd --no-debug                                         
 1244 ?        S      0:00 /usr/lib/systemd/systemd-logind                                               │ 1244 ?        Ss     0:00 /usr/lib/systemd/systemd-logind                                              
 1263 ?        S      0:00 /usr/sbin/irqbalance --foreground                                             │ 1263 ?        Ss     0:00 /usr/sbin/irqbalance --foreground                                            
 1267 ?        Sl     0:00 /usr/bin/dbus-daemon --system --address=systemd: --nofork --                  │ 1267 ?        Ssl    0:00 /usr/bin/dbus-daemon --system --address=systemd: --nofork --nopidfile --system
 1280 ?        S<     0:00 [kworker/1:1H]                                                                │ 1280 ?        S<     0:00 [kworker/1:1H]
 1308 ?        S      0:00 /sbin/rpcbind -w                                                              │ 1308 ?        Ss     0:00 /sbin/rpcbind -w
 1325 ?        Sl     0:00 /usr/sbin/gssproxy -D                                                         │ 1325 ?        Ssl    0:00 /usr/sbin/gssproxy -D
 1329 ?        S      0:00 /usr/sbin/chronyd                                                             │ 1329 ?        S      0:00 /usr/sbin/chronyd
 1529 ?        S      0:00 /usr/sbin/crond -n                                                            │ 1529 ?        Ss     0:00 /usr/sbin/crond -n
 1530 tty1     S      0:00 /sbin/agetty --noclear tty1 linux                                             │ 1530 tty1     Ss+    0:00 /sbin/agetty --noclear tty1 linux                                            
 2450 ?        S      0:00 /usr/sbin/sshd -D -u0                                                         │ 2450 ?        Ss     0:00 /usr/sbin/sshd -D -u0
 2453 ?        Sl     0:00 /usr/sbin/rsyslogd -n                                                         │ 2453 ?        Ssl    0:00 /usr/sbin/rsyslogd -n
 2454 ?        Sl     0:00 /usr/bin/python2 -Es /usr/sbin/tuned -l -P                                    │ 2454 ?        Ssl    0:00 /usr/bin/python2 -Es /usr/sbin/tuned -l -P                                   
 2708 ?        S      0:00 /usr/libexec/postfix/master -w                                                │ 2708 ?        Ss     0:00 /usr/libexec/postfix/master -w                                               
 2712 ?        S      0:00 pickup -l -t unix -u                                                          │ 2712 ?        S      0:00 pickup -l -t unix -u
 2713 ?        S      0:00 qmgr -l -t unix -u                                                            │ 2713 ?        S      0:00 qmgr -l -t unix -u
 3750 ?        Sl     0:00 /usr/sbin/NetworkManager --no-daemon                                          │ 3750 ?        Ssl    0:00 /usr/sbin/NetworkManager --no-daemon                                         
 3765 ?        S      0:00 /sbin/dhclient -d -q -sf /usr/libexec/nm-dhcp-helper -pf /va                  │ 3765 ?        S      0:00 /sbin/dhclient -d -q -sf /usr/libexec/nm-dhcp-helper -pf /var/run/dhclient-eth
 4406 ?        S      0:00 sshd: vagrant [priv]                                                          │ 4406 ?        Ss     0:00 sshd: vagrant [priv]
 4409 ?        S      0:00 sshd: vagrant@pts/0                                                           │ 4409 ?        S      0:00 sshd: vagrant@pts/0
 4410 pts/0    S      0:00 -bash                                                                         │ 4410 pts/0    Ss+    0:00 -bash
 4431 ?        S      0:00 sshd: vagrant [priv]                                                          │ 4431 ?        Ss     0:00 sshd: vagrant [priv]
 4434 ?        S      0:00 sshd: vagrant@pts/1                                                           │ 4434 ?        S      0:00 sshd: vagrant@pts/1
 4435 pts/1    S      0:00 -bash                                                                         │ 4435 pts/1    Ss     0:00 -bash
 4458 pts/0    S      0:00 bash ./ps.sh ax                                                               │ 9324 pts/1    R+     0:00 ps ax
[vagrant@centos7 ~]$                                                                                     │[vagrant@centos7 ~]$
```
</details>

Дополнение:  
Т.к. в файле `/proc/[pid]/stat` время указывается в тактах, то для получения его в секундах необходимо разделить на `sysconf (_SC_CLK_TCK)` (как указано в доккументации `man proc`). Программа [ticks.c](https://github.com/che-a/OTUS_LinuxAdministrator/blob/master/tasks/05/ticks.c) выполняет задачу получения значения `sysconf (_SC_CLK_TCK)`, которое обычно равно 100.
