### Chapter 3: Secure Your Code, Build and Deploy

This chapter focuses on secure coding practices, vulnerability prevention, and implementing security throughout the software development lifecycle. It emphasizes applying Zero Trust principles during development, build, and deployment phases.

### OWASP Top 10 - SQL Injection (A03: Injection)

[sql-injection.py](sql-injection.py) - Demonstrates SQL injection vulnerability and proper mitigation techniques:

**Vulnerable Code Example:**
- Shows how direct string concatenation of user input into SQL queries creates injection vulnerabilities
- Attackers can manipulate the query by appending malicious SQL clauses
- Example: `get_user_data_bad()` uses string concatenation to build the query

**Secure Code Example:**
- Demonstrates the correct approach using parameterized queries
- Prevents SQL injection by separating SQL code from user data
- Example: `get_user_data_good()` uses query parameters to safely handle user input

**Key Takeaway:** Never concatenate user input directly into SQL queries. Always use parameterized queries or prepared statements to prevent injection attacks, a critical component of Zero Trust security that assumes all input is untrusted.