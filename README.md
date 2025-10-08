# Game Store Analytics App
## Copyright 2023 Nedelcu Andrei-David
___________________________________________________________________________________________

### Local Deployment Instructions

First, run all the database files in SQL Server in the following order: create_tables, trigger, insert_into_tables, insert_into_tables2, procedures.

Then, make an App folder and open it in VS Code, which contains the application's source files (backend, your_database, static folder -> styles, templates folder -> customer_patterns, game_sales_review, home, revenue_by_category, sales_by_category, wishlist_additions). In the section Database connection details, fill in the SERVER field with your own SQL Server where the scripts were executed (replacing the existing value).

Next, run the backend.py script and visit the web link http://127.0.0.1:5000/. 
Enjoy!

For more info about the flow of the app and implementation details check the Documentation(RO).


