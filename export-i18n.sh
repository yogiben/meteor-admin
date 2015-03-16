#! sh
xgettext-template -D lib/client/html -L Handlebars *.html -o i18n/en.i18n.po
i18next-conv -l en -s i18n/en.i18n.po -t i18n/en.i18n.json
