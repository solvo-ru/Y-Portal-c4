Ваше приложение может выполнять две основные функции с помощью клиента:

1. **Активно вызывать Zeebe**, например, для начала процесных инстансов, корреляции сообщений с процессной инстанцией или развертывания процесных определений.
2. **Подписываться на задачи**, созданные в рабочем процессе в контексте BPMN-сервисных задач.

### Вызов Zeebe

С помощью клиента API Zeebe вы можете взаимодействовать с рабочим процессом. Два основных API-вызова являются вызовом новых процессных инстансов и корреляцией сообщений с процессной инстанцией.

**Вызов новых процессных инстансов с помощью Java-клиента:**

```java
ProcessInstance processInstance = zeebeClient.newCreateInstanceCommand()
  .bpmnProcessId("someProcess").latestVersion()
  .variables(someProcessVariablesAsMap)
  .send()
  .exceptionally(throwable -> { throw new RuntimeException("Could not create new instance", throwable); });
```

**Вызов новых процессных инстансов с помощью Node.js-клиента:**

```js
const processInstance = await zbc.createWorkflowInstance({
  bpmnProcessId: "someProcess",
  version: 5,
  variables: {
    testData: "something",
  },
});
```

**Корреляция сообщений с процессной инстанцией с помощью Java-клиента:**

```java
zeebeClient.newPublishMessageCommand() //
  .messageName("messageA")
  .messageId(uniqueMessageIdForDeduplication)
  .correlationKey(message.getCorrelationid())
  .variables(singletonMap("paymentInfo", "YeahWeCouldAddSomething"))
  .send()
  .exceptionally(throwable -> { throw new RuntimeException("Could not publish message " + message, throwable); });
```

**Корреляция сообщений с процессной инстанцией с помощью Node.js-клиента:**

```js
zbc.publishMessage({
  name: "messageA",
  messageId: messageId,
  correlationKey: correlationId,
  variables: {
    valueToAddToWorkflowVariables: "here",
    status: "PROCESSED",
  },
  timeToLive: Duration.seconds.of(10),
});
```

Это позволяет вам соединить Zeebe с любой внешней системой, написав некоторый собственный код. Мы покажем общие технологические примеры, чтобы иллюстрировать это.

### Подписка на задачи с помощью рабочего процесса

Чтобы реализовать сервисные задачи процесного модели, вам нужно написать код, который подписывается на рабочий процесс. В сущности, вы должны написать некоторый собственный код, который будет выполняться каждый раз, когда сервисная задача попадает на рабочий процесс (который внутренне создает задачу, поэтому и называется "задача").

**Открытие подписки с помощью Java-клиента:**

```java
zeebeClient
  .newWorker()
  .jobType("serviceA")
  .handler(new ExampleJobHandler())
  .timeout(Duration.ofSeconds(10))
  .open()) {waitUntilSystemInput("exit");}
```

**Открытие подписки с помощью Node.js-клиента:**

```js
zbc.createWorker({
  taskType: "serviceA",
  taskHandler: handler,
});
```

Вам также может потребоваться использовать интеграции в определенных программных фреймках, таких как [Spring Zeebe](https://github.com/camunda-community-hub/spring-zeebe/) в мире Java, которая начинает рабочий процесс и реализует подписку автоматически в фоне вашего собственного кода.

**Подписка для вашего собственного кода открывается автоматически с помощью Spring-интеграции:**

```java
@JobWorker(type = "serviceA")
public void handleJobFoo(final JobClient client, final ActivatedJob job) {
  // тут ваш собственный код, который будет выполняться каждый раз, когда сервисная задача попадает на рабочий процесс
  // вам не нужно вызывать "complete" на задачу, потому что autoComplete включен выше
}
```

Также есть документация о том, как писать хороший рабочий процесс.

## Технологические примеры



### REST

Вы можете написать кусок кода, который предоставляет REST-конец в языке программирования вашего выбора и затем начинает новую процессную инстанцию.

Например, в [примере Ticket Booking](https://github.com/berndruecker/ticket-booking-camunda-cloud) содержится пример для Java и Spring Boot, который предоставляет REST-конец для [запуска новой процессной инстанции](https://github.com/berndruecker/ticket-booking-camunda-cloud/blob/master/booking-service-java/src/main/java/io/berndruecker/ticketbooking/rest/TicketBookingRestController.java#L35).

Также вы можете использовать [Spring Boot-расширение](https://github.com/zeebe-io/spring-zeebe/) для начала рабочих процессов и подписки на выходящие REST-вызовы.

![REST-пример](connecting-the-workflow-engine-with-your-world-assets/rest-example.png)

Вы также можете найти [пример Node.js-клиента для REST-запросов](https://github.com/berndruecker/flowing-retail/blob/master/zeebe/nodejs/nestjs-zeebe/checkout/src/app.controller.ts) в [примере Flowing Retail](https://github.com/berndruecker/flowing-retail).

### Обмен данными

Вы также можете использовать тот же подход для обмена данными, который в настоящее время часто является [AMQP](https://en.wikipedia.org/wiki/Advanced_Message_Queuing_Protocol) сейчас.

В примере [Ticket Booking](https://github.com/berndruecker/ticket-booking-camunda-

Технологические примеры

Важно понимать, что для каждого технологического стека существует своя специфика. В данном разделе мы рассмотрим некоторые из них, чтобы помочь вам лучше понять, как использовать Zeebe в вашем конкретном контексте.

### REST

Один из самых распространенных способов взаимодействия с внешними системами - это использование RESTful API. Вы можете использовать любой поддерживаемый язык программирования для создания кода, который будет вызывать процессы инстанцирования.

[Пример Ticket Booking Example](https://github.com/berndruecker/ticket-booking-camunda-cloud/blob/master/booking-service-java/src/main/java/io/berndruecker/ticketbooking/rest/TicketBookingRestController.java#L35) содержит пример RESTful API, который вызывает процесс инстанцирования.

### Messaging

Если ваше приложение уже использует какое-либо сообщение-ориентированное взаимодействие, такое как AMQP, вы можете использовать его для взаимодействия с Zeebe.

[Пример Ticket Booking Example](https://github.com/berndruecker/ticket-booking-camunda-cloud/blob/master/booking-service-java/src/main/java/io/berndruecker/ticketbooking/adapter/RetrievePaymentAdapter.java) содержит пример использования RabbitMQ для взаимодействия с Zeebe.

### Apache Kafka

Вам также может потребоваться использовать Apache Kafka для взаимодействия с Zeebe. Это может быть полезным, если у вас уже есть инфраструктура Kafka, которую вы хотите использовать вместе с Zeebe.

[Пример Flowing Retail Example](https://github.com/berndruecker/flowing-retail/blob/master/kafka/java/order-zeebe/src/main/java/io/flowing/retail/kafka/order/messages/MessageListener.java#L39) содержит пример использования Kafka для взаимодействия с Zeebe.

### Рекомендации

Как правило, предпочитайте использовать свое собственное написание глю-кода, когда у вас нет хороших причин использовать существующий подключатель (как уже было упомянуто выше).

Хорошие причины для использования подключателей - это сценарии, где мало надобности в настройке, такие как [Camunda RPA bridge](https://docs.camunda.org/manual/latest/user-guide/camunda-bpm-rpa-bridge/), который скоро станет доступным для Camunda 8.

Некоторые сценарии также позволяют создать **реалізуемый универсальный адаптер**; например, для отправки статусных сообщений в вашу бизнес-интеллигентную систему.

Но есть и некоторые общие недостатки использования подключателей. Во-первых, возможности ограничены тем, что создатель подключателя заранее предусмотрел. В реальности вы можете столкнуться с ограничениями подключателя уже очень скоро.
