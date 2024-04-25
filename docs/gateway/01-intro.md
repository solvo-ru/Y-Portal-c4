# API Gateway

API Gateway - [шаблон](https://microservices.io/patterns/apigateway.html), позволяющий реализовать единую точку входа для сервисов системы. В качестве реализации используется [Spring Cloud Gateway](https://cloud.spring.io/spring-cloud-gateway/reference/html/), построенный на базе [Spring Boot 3.x](https://spring.io/projects/spring-boot#learn), [Spring WebFlux](https://docs.spring.io/spring/docs/current/spring-framework-reference/web-reactive.html) и [Project Reactor](https://projectreactor.io/docs). Ключевыми понятиями Spring Cloud Gateway являются:
- **Route** (**Маршрут**): основной строительный блок шлюза. Он определяется ID, целевым URI, набором предикатов и набором фильтров. Route считается определённым, если агрегатный предикат имеет значение `true`.
- **Predicate**: экземпляр [Java Function Predicate](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/function/Predicate.html). На вход предикат получает [Spring Framework `ServerWebExchange`](https://docs.spring.io/spring-framework/docs/6.1.x/javadoc-api/org/springframework/web/server/ServerWebExchange.html), что позволяет указать зависимость значения предиката от любых деталей HTTP-запроса, таких как заголовки и параметры
- **Filter**: экземпляр [Spring Framework `GatewayFilter`](https://docs.spring.io/spring/docs/6.1.x/javadoc-api/org/springframework/web/server/GatewayFilter.html), позволяющий изменять запросы и ответы до или после взаимодействия с целевым сервисом.

Настройки Spring Cloud Gateway задаются через конфигурацию приложения

Сервис **gateway** использует настройки Spring Cloud Gateway через конфигурацию и содержатся они в файле *config/applications/gateway-application-development.yml*:

**Consul** необходим для Service Discovery и, соответственно, маршрутизации запросов. Настройки соединения с ним указывается в файле *bootstrap.yml* приложения gateway:

**Redis** необходим для работы **RequestRateLimiter**, это единственная in-memory key-value хранилище, с которым на текущий момент интегрирован Spring Cloud Gateway. Redis запускается в отдельном докер-контейнере

Настройки соединения с ним также указываются в файле *bootstrap.yml*.

Для использования Spring Cloud Gateway необходимо подключить зависимость

Для использования RequestRateLimiter необходимо подключить зависимость

Полный список возможностей Spring Cloud Gateway указан в [спецификации](https://cloud.spring.io/spring-cloud-gateway/reference/html/).
