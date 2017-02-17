# Event store

This image listens for events in a RabbitMQ queue and save them into a PostgreSQL database.

## Events

A single projector is defined following [Happn-ruby](https://github.com/crepesourcing/happn-ruby): `SaveAllEventsProjector`.

## Environment variables

| Option | Default Value | Type | Required? | Description  | Example |
| ---- | ----- | ------ | ----- | ------ | ----- |
| `POSTGRES_DATABASE_docker push babili/engine:latestHOST` | `"localhost"`| String | Required | | `"192.168.42.42"` |
| `POSTGRES_DATABASE_PORT` | `5432`| Integer | Optional | | `4242` |
| `POSTGRES_DATABASE_USER` | `"postgres"`| String | Optional | | `"root"`|
| `POSTGRES_DATABASE_PASSWORD` | `""`| String | Optional | | `"12345"`|
| `POSTGRES_DATABASE_NAME` | `"event-store"`| String | Optional | | `"freezed-events"` | 
| `RABBITMQ_HOST` | `"localhost"` | String | Required | See [Happn's documentation](https://github.com/crepesourcing/happn-ruby)  | `"192.168.42.42"` |
| `RABBITMQ_PORT` | `"5672"` | String | Required | See [Happn's documentation](https://github.com/crepesourcing/happn-ruby)  | `"1234"` |
| `RABBITMQ_USER` | `""` | String | Required | See [Happn's documentation](https://github.com/crepesourcing/happn-ruby)  | `"root"` |
| `RABBITMQ_PASSWORD` | `""` | String | Required | See [Happn's documentation](https://github.com/crepesourcing/happn-ruby)  | `"pouet"` |
| `RABBITMQ_QUEUE_NAME` | `"events"` | String | Required | See [Happn's documentation](https://github.com/crepesourcing/happn-ruby)  | `"myproject"` |
| `RABBITMQ_EXCHANGE_NAME` | `"events"` | String | Required | See [Happn's documentation](https://github.com/crepesourcing/happn-ruby)  | `"myproject"` |
| `RABBITMQ_MANAGEMENT_PORT` | `"15672"` | String | Required | See [Happn's documentation](https://github.com/crepesourcing/happn-ruby)  | `"4242"` |
| `RABBITMQ_EXCHANGE_DURABLE` | `true` | Boolean | Optional | See [Happn's documentation](https://github.com/crepesourcing/happn-ruby)  | `false` |
| `RABBITMQ_QUEUE_NAME` | `"happn-queue"` | String | Required | See [Happn's documentation](https://github.com/crepesourcing/happn-ruby) | `"my-queue"` |
| `SENTRY_DSN` | `""` | String | Optional | If this variable is set, all error logs are sent to your [sentry.io](https://sentry.io) project. | `` |
| `REPLAY_TRESHOLD` | `200000` | Integer | Optional | When replaying events, a queue is frequently checked to not have more messages than `REPLAY_TRESHOLD`. If you want to disable this threshold feature, set this value to `0`. | `1000000` |
| `REPLAY_TRESHOLD_QUEUE_NAME` | `""` | String | Optional | When replaying events, a queue name must be specified to frequently check that a maximum number of messages does not overload the queue. The replaying service will wait for this queue to do not overload.  | `` |

## How to run this container

Starting this container will start listening for events.

```
$ docker run crepesourcing/event-store:latest
```

## How to replay

```
$ docker run --rm crepesourcing/event-store:latest bash -c 'rake events:replay'
```

## How to add my own migrations

Create a Dockerfile to include your own migrations. For instance:

```
FROM crepesourcing/event-store:latest
COPY db/migrate/* /usr/src/app/db/migrate/
```

## Build a new version

```
$ docker login -u babilideployer -p ${DOCKERHUB_PASSWORD} -e ${DOCKERHUB_EMAIL}
$ docker build --build-arg APP_ENV=production -t crepesourcing/event-store:latest .
$ docker push crepesourcing/event-store:latest
```
