# <img src="/.img/icon_bash.png"/> BASH-Helpers

<br />

###### Набор для облегчения разработки bash-скриптов

<br />

### Шаблоны скриптов

Находятся в каталоге [`scripts`](https://github.com/vitalyprohorenko/bash-helpers/tree/master/scripts)

Шаблонные скрипты с минимальным наполнением

<br />

### Библиотеки

Расположены в каталоге [`libraries`](https://github.com/vitalyprohorenko/bash-helpers/tree/master/libraries), скрипты с примерами использования в каталоге [`libraries/.tests`](https://github.com/vitalyprohorenko/bash-helpers/tree/master/libraries/.tests)

Каждая библиотека построена на функциях и может быть вызвана как из скрипта, так и в консоли

Некоторые библиотеки используют прерывания (SIGUSR, SIGWINCH и т.п.)

##### Подключение и применение

Библиотекам не обязательно давать права на запуск (`chmod +x`), права на запуск должны быть у импортирующего скрипта

Для использования, файл нужно импортировать в свой скрипт или консоль командой `source`

`source ./имя_библиотеки.shlib` или `. ./имя_библиотеки.shlib`

Справочная информация интегрирована в библиотеки с двойным комментарием `##` и просматривается командой `cat имя_библиотеки.shlib | grep -E "^##"`

<br />

### Специальные метки

<img src="/.img/icon_g.png"/> Релиз

<img src="/.img/icon_y.png"/> beta-версия

<img src="/.img/icon_r.png"/> В разработке
