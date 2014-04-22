Cancer 台灣癌症資料專案
=======================

資料來源: 衛生福利部
*  http://www.mohw.gov.tw/cht/DOS/Statistic.aspx?f_list_no=312&fod_list_no=4730

Usage
=======================

livescript is needed. 

    npm install request xlsjs LiveScript
    ./node_modules/.bin/lsc main.ls

Raw data will be kept in raw/, separated by year in different folders. A converted csv file is also generated for each xls file. Total numbers in each town are also formatted into a json file named "total.json" in root directory.


License
=======================

MIT License (for Source code)
