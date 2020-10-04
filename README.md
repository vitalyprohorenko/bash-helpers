# <img src="/.img/icon_bash.png"/> BASH-Helpers

<br />

> Набор вспомогательных функций для облегчения создания bash-скриптов
>
> Каждая библиотека построена на функциях и может быть вызвана как из скрипта, так и в консоли
>
> Некоторые библиотеки используют прерывания (SIGUSR, SIGWINCH и т.п.)

<br />

### Подключение и применение

Библиотекам не обязательно давать права на запуск (`chmod +x`), права на запуск должны быть у импортирующего скрипта

Для использования, файл нужно импортировать в свой скрипт или консоль командой `source`

`source ./имя_библиотеки.shlib` или `. ./имя_библиотеки.shlib`

Справочная информация интегрирована в библиотеки с двойным комментарием `##`

и просматривается командой `cat имя_библиотеки.shlib | grep -E "^##"`

<br />

### Файлы и каталоги

Путь к библиотекам: `имя_библиотеки/имя_библиотеки.version.shlib`

Примеры использования: `_testExamples/имя_библиотеки.example.sh`

<br />

### Список библиотек

<img src="/.img/icon_g.png"/> Релиз || <img src="/.img/icon_y.png"/> beta-версия || <img src="/.img/icon_r.png"/> В разработке

------

- <img src="/.img/icon_g.png"/> [`1th-template`](https://github.com/vitalyprohorenko/bash-helpers/tree/master/1th-template)

	Заготовка sh-скрипта с минимальной обвязкой

- <img src="/.img/icon_g.png"/> [`control-key`](https://github.com/vitalyprohorenko/bash-helpers/tree/master/control-key)

	Работа с stdin, считывание клавиш для управления и навигации

- <img src="/.img/icon_g.png"/> [`menu-creator`](https://github.com/vitalyprohorenko/bash-helpers/tree/master/menu-creator)

  Создание псевдо-графического меню

- <img src="/.img/icon_g.png"/> [`logger`](https://github.com/vitalyprohorenko/bash-helpers/tree/master/logger)

	Удобная работа с лог-файлом и stdout

- <img src="/.img/icon_g.png"/> [`async-timer`](https://github.com/vitalyprohorenko/bash-helpers/tree/master/async-timer)

  Асинхронный таймер

- <img src="/.img/icon_g.png"/> [`process-locker`](https://github.com/vitalyprohorenko/bash-helpers/tree/master/process-locker)

  Облегчёная работа с .lock файлом

- <img src="/.img/icon_r.png"/> `config-ini`

  Работа с ini-файлами, считывание и сохранение настроек

- <img src="/.img/icon_r.png"/> `json-parser`

  Использование строки в формате json как объекта

- <img src="/.img/icon_r.png"/> `app-controller`

  Обертка для гибкого запуска приложений