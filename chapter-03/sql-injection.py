# A03 Injection (SQL injection): 
# The following Python code takes a parameter and dynamically searches. 
# The first example (labeled as vulnerable) concatenates user input directly into the query, making it vulnerable to 
# SQL injection, as the attacker can append additional clauses to the statement. 
# The second example (labeled as corrected) uses a parameterized query.

from django.db import connection
cursor = connection.cursor()

def get_user_data_bad(username): # vulnerable 
    query = "SELECT * FROM users WHERE username = '" + username + "'"
    cursor.execute(query)

def get_user_data_good(username): # corrected
    cursor.execute("SELECT * FROM users WHERE username = ?", (username))
