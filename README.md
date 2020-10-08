# Kafka Producer

Simple Ruby utility to publish random messages to Kafka in Heroku.

## Gotchas

* Topic must be created in Kafka add-on
* Topic name must be set in the env as `KAFKA_TOPIC`
* Topics are prefixed with `KAFKA_PREFIX` in Heroku multitenant

## Produce Random Order

Once this folder has been deployed to Heroku, run:

```bash
heroku run ./bin/produce.sh -a kafka-producer
```

The output looks like:

```bash
===============================================
	Publish random order to Kafka: START...
===============================================
	KAFKA_PREFIX: canadian-28050.
	KAFKA_TOPIC: orders
	topic: canadian-28050.orders
===============================================
	Publish random order to Kafka: ...DONE
===============================================
```

To verify run `heroku kafka:topics:tail <KAFKA_PREFIX><KAFKA_TOPIC> -a
kafka-producer` in the terminal, the output looks like:

```bash
heroku kafka:topics:tail canadian-28050.orders -a kafka-producer
canadian-28050.orders 0 1 918 {"key":"b1ae0f40-a49d-4870-90e2-df5dae773453","value":{"status":"in_progress","c
```
