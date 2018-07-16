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
| `REPLAY_TRESHOLD_QUEUE_NAME` | `""` | String | Optional | When replaying events, a queue name must be specified to frequently check that a maximum number of messages does not overload the queue. The replaying service will wait for this queue to do not overload.  | ` ` |

## How to run this container

Starting this container will start listening for events.

```
$ docker run crepesourcing/event-store:latest
```

## How to replay all events

* All events:

```
$ docker run --rm crepesourcing/event-store:latest bash -c 'rake events:replay'
```
* All events starting from ID=1000

```
$ docker run --rm crepesourcing/event-store:latest bash -c 'rake events:replay[1000]'
```

## How to replay events to a single queue

* Looking for a single queue's bindings, delete all other queues and replay relevant events only.

```
$ docker run --rm crepesourcing/event-store:latest bash -c 'rake events:replay_single[1,"my-target-queue"]'
```


## How to reorder events

```
$ docker run --rm crepesourcing/event-store:latest bash -c 'rake events:reorder'
```


## How to add my own migrations

Create a Dockerfile to include your own migrations. For instance:

```
FROM crepesourcing/event-store:latest
COPY db/migrate/* /usr/src/app/db/migrate/
```

## How to prevent some events to be saved

By default, all events are saved into the event-store.  However, you can provide a Ruby class named `EventIgnoreStrategy` that implements `should_ignore?(happn_event)` and replace it in your Docker container:
```
FROM crepesourcing/event-store:latest
COPY your-strategy.rb /usr/src/app/app/services/event_ignore_strategy.rb
```

## How to add my own event projectors

To add and register your own implementations `Happn::Projector`, add all their ruby files to the folder `app/projectors/` and add their class name to environment variable `CUSTOM_PROJECTORS` (separated by a comma).

## Build a new version

```
$ docker login -u ${DOCKERHUB_USER} -p ${DOCKERHUB_PASSWORD} -e ${DOCKERHUB_EMAIL}
$ docker build -t crepesourcing/event-store:latest .
$ docker push crepesourcing/event-store:latest
```

(but this project is automatically built on DockerHub anyway: https://hub.docker.com/r/crepesourcing/event-store)
