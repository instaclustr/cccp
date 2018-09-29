keyspace: stresscql2

keyspace_definition: |
  CREATE KEYSPACE stresscql2 WITH replication = {'class': 'NetworkTopologyStrategy', '${dc}': ${num_nodes}};

table: twcstestbucket

table_definition: |
  CREATE TABLE twcstestbucket (
  id text,
  bucket timestamp,
  time timestamp,
  metric int,
  value blob,
  PRIMARY KEY((id, bucket), time)
  ) WITH CLUSTERING ORDER BY (time DESC)
  AND compaction = { 'class':'TimeWindowCompactionStrategy', 'compaction_window_unit':'MINUTES', 'compaction_window_size':'20', 'archive_sstable_after_size':'30', 'archive_sstable_after_unit':'MINUTES' }
  AND comment='A table to see what happens with TWCS & Stress'

columnspec:
  - name: id
    size: fixed(64)
    population: uniform(1..1500M)
  - name: time
    cluster: fixed(288)
  - name: value
    size: fixed(500) # Whatever;

insert:
  partitions: fixed(1)
  batchtype: UNLOGGED
  select: uniform(1..10)/10

queries:
  putindata:
    cql: insert into twcstestbucket (id, bucket, time, metric, value) VALUES (?, bucket(nowInMilliSec()), toTimestamp(now()), ?, ?)
  simple1:
    cql: select * from twcstestbucket where id = ? and bucket = bucket(nowInMilliSec()) and time <= toTimestamp(now()) and time >= minutesAgo(5)
    fields: samerow             # samerow or multirow (select arguments from the same row, or randomly from all rows in the partition)
  selectold:
    cql: select * from twcstestbucket where id = ? and bucket = randomBucket(1524115200000, 1524129600000)
    fields: samerow