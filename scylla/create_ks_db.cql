CREATE KEYSPACE test_keyspace WITH REPLICATION = { 'class' : 'NetworkTopologyStrategy','north' : 3};

USE test_keyspace;

CREATE TABLE tab_STCS (
id UUID PRIMARY KEY,
first_name text,
last_name text,
location int)
WITH compaction = {'class': 'SizeTieredCompactionStrategy'};

CREATE TABLE tab_LCS (
id UUID PRIMARY KEY,
first_name text,
last_name text,
location int)
WITH compaction = {'class': 'LeveledCompactionStrategy'};

CREATE TABLE tab_TWCS (
id UUID PRIMARY KEY,
first_name text,
last_name text,
location int)
WITH compaction = {
  'class' : 'TimeWindowCompactionStrategy',
  'compaction_window_unit' : 'MINUTES',
  'compaction_window_size' : 30}
AND default_time_to_live = 60;
