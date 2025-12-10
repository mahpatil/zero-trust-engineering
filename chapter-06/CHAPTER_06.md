### Chapter 6: Secure Your Data

This chapter focuses on protecting data at rest and in transit, implementing encryption strategies, and ensuring data confidentiality and integrity. Field-level encryption is a critical Zero Trust control that ensures sensitive data remains encrypted even if the database is compromised.

##  Field-Level Encryption

Field-level encryption (also known as column-level encryption) allows you to encrypt specific sensitive fields within database tables, ensuring that even database administrators cannot access plaintext sensitive data without proper decryption keys.

### 1 - SQL Server Always Encrypted

[1-field-level-enc-sql.sql](1-field-level-enc-sql.sql) - Demonstrates SQL Server's Always Encrypted feature for protecting sensitive customer data:

**Table Structure:**
Creates a `Customers` table with field-level encryption on sensitive columns.

**Encrypted Fields:**

1. **Name Field (Randomized Encryption):**
   - Uses `ENCRYPTION_TYPE = RANDOMIZED`
   - Same plaintext values produce different ciphertext each time
   - More secure but prevents equality searches and comparisons
   - Ideal for data that doesn't need to be queried directly

2. **NationalId Field (Deterministic Encryption):**
   - Uses `ENCRYPTION_TYPE = DETERMINISTIC`
   - Same plaintext always produces the same ciphertext
   - Enables equality searches, joins, and indexing
   - Suitable for fields that need to be searchable

**Encryption Configuration:**
- **Algorithm:** `AEAD_AES_256_CBC_HMAC_SHA_256` - Authenticated encryption providing both confidentiality and integrity
- **Column Encryption Key (CEK):** `MyCEK` - Symmetric key used to encrypt column data
- **Age Field:** Remains unencrypted as it's not considered sensitive

**Zero Trust Benefits:**
- Data remains encrypted in the database, backups, and memory
- Protection against database administrator access
- Separation of duties between DBAs and data owners
- Encryption happens at the client side, keeping keys away from the database server

---

### 2 - MongoDB Client-Side Field-Level Encryption

[2-field-level-enc-mongo.java](2-field-level-enc-mongo.java) - Implements client-side field-level encryption (CSFLE) for MongoDB using Java:

**Key Components:**

1. **Data Encryption Key (DEK):**
   - Base64-encoded key identifier used to encrypt specific fields
   - Stored in a key vault collection separate from application data

2. **JSON Schema Definition:**
   - Defines which fields should be encrypted and how
   - Specifies encryption algorithm: `AEAD_AES_256_CBC_HMAC_SHA_512-Deterministic`
   - Example shows SSN field encryption with deterministic encryption for equality queries
   - Uses BSON type specification for encrypted fields

3. **Auto-Encryption Settings:**
   - **Key Vault Namespace:** Specifies where encryption keys are stored
   - **KMS Providers:** Configures Key Management Service for master key protection
   - **Schema Map:** Maps collections to their encryption schemas
   - Automatic encryption/decryption handled by MongoDB driver

4. **Client Configuration:**
   - `MongoClientSettings` configured with auto-encryption
   - Transparent encryption at the application layer
   - Keys never exposed to the database server

**Encryption Flow:**
1. Application defines which fields need encryption via schema
2. MongoDB driver automatically encrypts data before sending to server
3. Driver automatically decrypts data when reading from server
4. Database stores only encrypted data (ciphertext)

**Zero Trust Implementation:**

- **Client-Side Encryption:** Data encrypted before leaving the application
- **Key Separation:** Encryption ed datakeys stored separately from encrypt
- **Deterministic Encryption:** Enables secure equality queries while maintaining encryption
- **Minimal Trust:** Database server never sees plaintext data or encryption keys
- **Defense in Depth:** Even if database is compromised, data remains protected

**Use Case:**
Ideal for applications storing sensitive data like medical records, financial information, or personally identifiable information (PII) where regulatory compliance requires encryption at rest and separation of duties.

**Key Takeaway:** Field-level encryption, whether in SQL Server or MongoDB, embodies Zero Trust principles by ensuring that sensitive data is encrypted at the application level and remains protected throughout its lifecycle, even from privileged database users. This "encrypt everywhere" approach assumes that any component (including the database) could be compromised.