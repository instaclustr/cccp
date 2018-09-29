CREATE OR REPLACE FUNCTION stresscql2.nowInMilliSec()
    RETURNS NULL ON NULL INPUT
    RETURNS bigint
    LANGUAGE java
    AS $$
    return (System.currentTimeMillis()); $$;


CREATE OR REPLACE FUNCTION stresscql2.minutesAgo ( arg int )
    RETURNS NULL ON NULL INPUT
    RETURNS bigint
    LANGUAGE java
    AS $$
    return (System.currentTimeMillis() - arg * 60 * 1000); $$;

CREATE OR REPLACE FUNCTION stresscql2.bucket( arg bigint )
    RETURNS NULL ON NULL INPUT
    RETURNS bigint
    LANGUAGE java
    AS $$
     java.time.ZonedDateTime time = java.time.ZonedDateTime.ofInstant(java.time.Instant.ofEpochMilli(arg), java.time.ZoneOffset.UTC);
     java.time.ZonedDateTime lastFiveMinutes = time.truncatedTo(java.time.temporal.ChronoUnit.HOURS)
                    .plusMinutes(5 * (time.getMinute()/5));
     return (lastFiveMinutes.toEpochSecond() * 1000);
     $$;

CREATE OR REPLACE FUNCTION stresscql2.randomBucket(lowerbound bigint, upperbound bigint)
    RETURNS NULL ON NULL INPUT
    RETURNS bigint
    LANGUAGE java
    AS $$
    java.time.ZonedDateTime lower = java.time.ZonedDateTime.ofInstant(java.time.Instant.ofEpochMilli(lowerbound), java.time.ZoneOffset.UTC);
    java.util.Random random = new java.util.Random();

    int numberOfBuckets = (int) (upperbound - lowerbound) / (5 * 60 * 1000);
    int targetBucket = random.nextInt(numberOfBuckets);

    return (lower.truncatedTo(java.time.temporal.ChronoUnit.HOURS).plusMinutes(5 * (lower.getMinute()/5)).plusMinutes(5 * targetBucket).toEpochSecond() * 1000);
    $$;
