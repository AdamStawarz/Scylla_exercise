
CREATE KEYSPACE test_keyspace WITH REPLICATION = { 'class' : 'NetworkTopologyStrategy','north' : 3};

USE test_keyspace;

CREATE TABLE tab_STCS (
first_name text,
last_name text, 
location int, 
PRIMARY KEY((first_name, last_name)))
WITH compaction = {'class': 'SizeTieredCompactionStrategy'};

CREATE TABLE tab_LCS (
first_name text,
last_name text, 
location int, 
PRIMARY KEY((first_name, last_name)))
WITH compaction = {'class': 'LeveledCompactionStrategy'};

CREATE TABLE tab_TWCS (
first_name text,
last_name text, 
location int, 
PRIMARY KEY((first_name, last_name)))
WITH compaction = {
  'class' : 'TimeWindowCompactionStrategy',
  'compaction_window_unit' : 'MINUTES',
  'compaction_window_size' : 30}
AND default_time_to_live = 60;