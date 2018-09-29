#
# Instaclustr standard YAML profile for cassandra-stress
# adapted from Apache Cassandra example file
#
# Insert data:
# cassandra-stress user profile=stress-spec.yaml n=25000000 cl=QUORUM ops\(insert=1\) -node file=node_list.txt -rate threads=100
# Note: n=25,000,000 will produce ~280G of data
# ensure all compactions are complete before moving to mixed load test
#
# Mixed load test
# cassandra-stress user profile=stress-spec.yaml duration=4h cl=QUORUM ops\(insert=1,simple1=10,range1=1\) -node file=node_list.txt -rate threads=30 -log file=mixed_run2_cms.log
#
#
# Keyspace info
#
keyspace: stresscql2

#
# The CQL for creating a keyspace (optional if it already exists)
#
#keyspace_definition: |
#  CREATE KEYSPACE stresscql2 WITH replication = {'class': 'NetworkTopologyStrategy', 'AWS_VPC_US_WEST_2': 3};

keyspace_definition: |
  CREATE KEYSPACE stresscql2 WITH replication = {'class': 'NetworkTopologyStrategy', '${dc}': ${num_nodes} };

#
# Table info
#
table: typestest

#
# The CQL for creating a table you wish to stress (optional if it already exists)
#
table_definition: |
  CREATE TABLE typestest (
  name text,
  choice boolean,
  date timestamp,
  address inet,
  dbl double,
  lval bigint,
  ival int,
  uid timeuuid,
  value blob,
  PRIMARY KEY((name,choice), date, address, dbl, lval, ival, uid)
  ) WITH COMPACT STORAGE
  AND compaction = { 'class':'LeveledCompactionStrategy' }
  AND comment='A table of many types to test wide rows'
#
# Optional meta information on the generated columns in the above table
# The min and max only apply to text and blob types
# The distribution field represents the total unique population
# distribution of that column across rows.  Supported types are
#
#      EXP(min..max)                        An exponential distribution over the range [min..max]
#      EXTREME(min..max,shape)              An extreme value (Weibull) distribution over the range [min..max]
#      GAUSSIAN(min..max,stdvrng)           A gaussian/normal distribution, where mean=(min+max)/2, and stdev is (mean-min)/stdvrng
#      GAUSSIAN(min..max,mean,stdev)        A gaussian/normal distribution, with explicitly defined mean and stdev
#      UNIFORM(min..max)                    A uniform distribution over the range [min, max]
#      FIXED(val)                           A fixed distribution, always returning the same value
#      Aliases: extr, gauss, normal, norm, weibull
#
#      If preceded by ~, the distribution is inverted
#
# Defaults for all columns are size: uniform(4..8), population: uniform(1..100B), cluster: fixed(1)
#
columnspec:
  - name: name
    size: uniform(1..1000)
    population: uniform(1..500M)     # the range of unique values to select for the field (default is 100Billion)
  - name: date
    cluster: uniform(20..1000)
  - name: lval
    population: gaussian(1..1000)
    cluster: uniform(1..4)
  - name: value
    size: uniform(100..500)

insert:
  partitions: fixed(1)       # number of unique partitions to update in a single operation
  # if batchcount > 1, multiple batches will be used but all partitions will
  # occur in all batches (unless they finish early); only the row counts will vary
  batchtype: UNLOGGED               # type of batch to use
  select: uniform(1..10)/10       # uniform chance any single generated CQL row will be visited in a partition;
  # generated for each partition independently, each time we visit it

#
# List of queries to run against the schema
#
queries:
  simple1:
    cql: select * from typestest where name = ? and choice = ? LIMIT 1
    fields: samerow             # samerow or multirow (select arguments from the same row, or randomly from all rows in the partition)
  range1:
    cql: select name, choice, uid  from typestest where name = ? and choice = ? and date >= ? LIMIT 10
    fields: multirow            # samerow or multirow (select arguments from the same row, or randomly from all rows in the partition)
  simple2:
    cql: select name, choice, uid from typestest where name = ? and choice = ? LIMIT 1
    fields: samerow             # samerow or multirow (select arguments from the same row, or randomly from all rows in the partition)