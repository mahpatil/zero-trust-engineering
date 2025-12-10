String dekId = "<paste-base-64-encoded-data-encryption-key-id>>";
//create an encryption json schema
Document jsonSchema = new Document().
    append("bsonType", "object").
    append("encryptMetadata", new Document().append(<keys>))
    append("properties", new Document().append(<properties>))
    //for encrypted properties append the properties in the following example
    .append("ssn", new Document().append("encrypt", new Document()))
    .append("bsonType", "int")
    .append("algorithm", "AEAD_AES_256_CBC_HMAC_SHA_512-Deterministic"))
//initialize schemaMap
HashMap<String, BsonDocument> schemaMap = new HashMap<String, BsonDocument>();
schemaMap.put("medicalRecords.patients", BsonDocument.parse(jsonSchema.toJson()));

//populate client settings with schema configuration
MongoClientSettings clientSettings = MongoClientSettings.builder()
    .applyConnectionString(new ConnectionString(connectionString))
    .autoEncryptionSettings(AutoEncryptionSettings.builder()
        .keyVaultNamespace(keyVaultNamespace)
        .kmsProviders(kmsProviders)
        .schemaMap(schemaMap)
        .extraOptions(extraOptions)
        .build())
    .build();
//create and store patient data for more details see reference link [21]