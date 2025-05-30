#!/bin/sh

# Проверка аргументов
if [ $# -eq 0 ]; then
  echo "Использование: $0 'строка поиска' [лимит]"
  exit 1
fi

# Экранирование кавычек (совместимый с /bin/sh способ)
SEARCH_TERM=$(echo "$1" | sed "s/'/''/g")
LIMIT=${2:-20}

# Простой SQL-запрос без сложных функций
QUERY="SELECT
  id,
  title,
  salary_from,
  salary_to,
  created_at
FROM
  vacancy
WHERE
  MATCH('@title \"$SEARCH_TERM\"')
ORDER BY
  WEIGHT() DESC,
  salary_to DESC
LIMIT $LIMIT"

# Выполнение запроса и форматирование вывода
mysql -P9306 -h0 -N -e "$QUERY" | awk -F'\t' '
function escape(s) {
  gsub(/'\''/, "'\''\\'\'''\''", s)  # Экранируем одинарные кавычки
  return s
}
BEGIN {
  printf "%-8s %-40s %-10s %-10s %-20s\n",
  "ID", "Должность", "ЗП от", "ЗП до", "Дата"
  print "-------------------------------------------------------------------------------"
}
{
  # Обрезаем title до 40 символов
  title = length($2) > 40 ? substr($2, 1, 37) "..." : $2

  # Конвертируем timestamp в дату (универсальный способ)
  if ($5 ~ /^[0-9]+$/) {
    cmd = "date -d @" $5 " +\"%Y-%m-%d %H:%M:%S\" 2>/dev/null"
    cmd | getline date
    close(cmd)
  } else {
    date = $5
  }

  printf "%-8s %-40s %-10s %-10s %-20s\n",
    $1, escape(title), $3, $4, date
}'

exit 0