 ALTER TABLE messages
   ADD is_spam BOOLEAN;

UPDATE messages
   SET is_spam = FALSE
 WHERE is_spam IS NULL;

 ALTER TABLE messages
 ALTER COLUMN is_spam
   SET NOT NULL;
