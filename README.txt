---Instructiuni deploy local---
Mai intai se ruleaza in sql server toate fisierele bazei
de date (aflate in SQLScrips)in ordinea urmatoare: create_tables,
trigger, insert_into_tables, insert_into_tables2, procedures.
Apoi se deschide in VS Code folderul App in care sunt fisierele
sursa ale aplicatiei si la sectiunea (# Database connection details)
completam la "SERVER", in loc de ce scrie acolo se va trece
propriul server sql unde s-au rulat scripturile, se va rula
scriptul backend.py si se va vizita pe web linkul
http://127.0.0.1:5000/. Enjoy!
