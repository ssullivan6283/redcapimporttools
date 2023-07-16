@echo off
C:
PATH C\Program Files\R\R-4.2.1\bin;%path$
cd C:\Program Files\R\R-4.2.1\bin
Rscript single-field-dag-assignment-import.R
timeout /t 300 /nobreak >nul
exit