#  <img src="bash.png"/> BASH-Helpers



###### ***Набор вспомогательных функций для использования в bash-скриптах***



#### Использование

Для использования нужно импортировать в свой скрипт или консоль командой source

`source ./имя_библиотеки.shlib` или `. ./имя_библиотеки.shlib`

Справочная информация интегрирована в библиотеки с двойным комментарием `##`

и просматривается командой `cat имя_библиотеки.shlib | grep -E "^##"`



#### Файлы и каталоги

Путь к библиотекам: `имя_библиотеки/имя_библиотеки.version.shlib`

Примеры использования: `имя_библиотеки.example.sh`



#### Список библиотек

- `control-key`

  ​	Работа с stdin, считывание клавиш для управления и навигации

- `menu-creator`

  ​	Создание псевдо-графического меню