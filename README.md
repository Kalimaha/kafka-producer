# Kafka Producer

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

Simple Ruby utility to publish random messages to Kafka in Heroku.

## Gotchas _(setup)_

* Topic must be created in Kafka add-on
* Topic name must be set in the env as `KAFKA_TOPIC`
* Topics are prefixed with `KAFKA_PREFIX` in Heroku multitenant

## Publish Random Order

Once this folder has been deployed to Heroku, run:

```bash
heroku run ./bin/produce.sh -a kafka-producer
```

The output looks like:

```bash
===============================================
	Publish random order to Kafka: START...
===============================================
{:key=>"76b55546-b4b2-45b4-9f2d-d84c75660992",
 :value=>
  {:status=>"in_progress",
   :centsPrice=>11085,
   :currency=>"AUD",
   ...
===============================================
	Publish random order to Kafka: ...DONE
===============================================
```

To verify that the publishing is happening, you can run _(in a different terminal)_:

```bash
heroku kafka:topics:tail <KAFKA_PREFIX><KAFKA_TOPIC> -a kafka-producer
```

The output looks like:

```bash
heroku kafka:topics:tail canadian-28050.orders -a kafka-producer
canadian-28050.orders 0 1 918 {"key":"b1ae0f40-a49d-4870-90e2-df5dae773453","value":{"status":"in_progress","c
```
