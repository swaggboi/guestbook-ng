ALTER TABLE messages
ALTER COLUMN message_date
  SET DEFAULT NOW();
