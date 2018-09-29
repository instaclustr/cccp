keyspace: stresscql2

keyspace_definition: |
  CREATE KEYSPACE stresscql2 WITH replication = {'class': 'NetworkTopologyStrategy', '${dc}': ${num_nodes}};

table: twcstest

table_definition: |
  CREATE TABLE twcstest (
  id text,
  time timestamp,
  metric int,
  value blob,
  PRIMARY KEY((id), time)
  ) WITH CLUSTERING ORDER BY (time DESC)
  AND compaction = { 'class':'TimeWindowCompactionStrategy', 'compaction_window_unit':'MINUTES', 'compaction_window_size':'20' }
  AND comment='A table to see what happens with TWCS & Stress'

columnspec:
  - name: id
    size: fixed(64)
    population: uniform(1..1500M)
  - name: time
    cluster: fixed(288)
  - name: value
    size: fixed(50) # Whatever;

insert:
  partitions: fixed(1)
  batchtype: UNLOGGED
  select: uniform(1..10)/10

queries:
  putindata:
    cql: insert into twcstest (id, time, metric, value) VALUES (?, toTimestamp(now()), ?, ?)
  simple1:
    cql: select * from twcstest where id = ? and time <= toTimestamp(now()) and time >= minutesAgo(5)
    fields: samerow             # samerow or multirow (select arguments from the same row, or randomly from all rows in the partition)
  selectold:
    cql: select * from twcstest where id = ? and time >= minutesAgo(600) and time <= minutesAgo(590)
    fields: samerow