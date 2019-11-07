#!/usr/bin/env bash

PROGNAME=`basename $0`
#
# Массив PID заполняем идентификаторами процессов из каталога /proc/
PIDS=(`ls /proc/ | grep "^[0-9]" | sort -n`)
TTY=
STAT=
TIME=
CMD=

# Функция записывает в переменную TTY название связанного с процессом терминала
# Параметры: $1 -- PID процесса
function get_tty {
    # TTY_NR -- это поле tty_nr в файле /proc/[pid]/stat
    # Согласно документации:
    #   The minor device number is contained in the combination of bits 31 to 20
    #   and 7 to 0; the major device number is in bits 15 to 8.
    # В этой программе биты с 31-го по 20-й не рассматриваются (для упрощения).
    # Далее идет преобразование в двоичную форму представления числа, разделение
    #   этого числа на мажорную и минорную части и преобразование каждой из них
    #   в десятичную форму для дальнейшего использования.
    local TTY_NR=`cat /proc/$1/stat | gawk '{print $7}'`
    local BIN=$( printf "%016d" `echo "obase=2;$TTY_NR" | bc` )
    local BIN_MAJOR=`echo $BIN | gawk '{print substr ($0, 0, 8)}'`
    local BIN_MINOR=`echo $BIN | gawk '{print substr ($0, 9, 16)}'`
    local DEC_MAJOR=`echo "ibase=2;$BIN_MAJOR" | bc`
    local DEC_MINOR=`echo "ibase=2;$BIN_MINOR" | bc`

    # Определение названия терминала.
    # Данные для выбора взяты из файла /proc/devices

    case $DEC_MAJOR in
        4)      TTY='tty/'$DEC_MINOR
                ;;
        128)    TTY='ptm/'$DEC_MINOR
                ;;
        136)    TTY='pts/'$DEC_MINOR
                ;;
        *)      TTY='?'
                ;;
    esac
}

function get_stat {
    STAT=`cat /proc/$1/status | grep State | gawk '{print $2}'`
    local flag_hp=      # high-priority (not nice to other users)
    local flag_N=       # low-priority (nice to other users)
    local flag_L=       # has pages locked into memory (for real-time and custom IO)
    local flag_s=       # is a session leader
    local flag_l=`cat /proc/$1/status | grep Threads | gawk '{print $2}'`       # is multi-threaded (using CLONE_THREAD, like NPTL pthreads do)
    local flag_plus=    # is in the foreground process group

    if [ $flag_l -gt 1 ]; then
        STAT=$STAT"l"
    fi
}

function get_time {
    TIME='X:XX'
}

function get_command {
    CMD=`cat /proc/$1/cmdline | tr '\0' ' '`
    if [[ -z $CMD ]]; then
        CMD='['`cat /proc/$1/status | grep Name | gawk '{print $2}'`']'
    else
        CMD=`echo $CMD | awk '{print substr ($0, 0, 60)}'`
    fi
}

function ps_ax {

    echo "  PID TTY      STAT   TIME COMMAND"

    for PID in ${PIDS[@]}; do
        # На момент перебора некоторых процессов уже может не существовать
        if [ -d "/proc/$PID" ]; then
            get_tty $PID        # Поле TTY
            get_stat $PID       # Поле STAT
            get_time $PID       # Поле TIME
            get_command $PID    # Поле CMD

            # Команда printf некорректно выводит заданное число символов строки,
            # которые содержат пробелы
            printf "%5d %-8s %-6s %4s %s \n" $PID $TTY $STAT $TIME "$CMD"
        fi
    done
}

function print_usage {
    echo -e "\n$PROGNAME - реализация на bash программы ps ax"
    echo -e "Использование: $PROGNAME [ -ax | -h | -v ]\n"
}

case $1 in
    -ax)                ps_ax
                        ;;

    -h | --help)        print_usage
                        ;;

    -v)                 echo "Админитсратор Linux"
                        ;;

    *)                  print_usage >&2
                        exit 1
                        ;;
esac
