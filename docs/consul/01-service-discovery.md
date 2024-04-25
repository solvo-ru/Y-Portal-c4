## Service Discovery

Service Discovery позволяет клиенту обращаться к нужному сервису без указания информации о физическом расположении сервиса, достаточно указать логическое имя сервиса и процесс Service Discovery определит набор доступных инстансов сервиса.

Выбрана реализация Service Discovery на базе [HashiCorp Consul](https://www.consul.io/) из-за значительно более богатой функциональности, больших гарантий надёжности и/или большей простоты использования по сравнению с альтернативными решениями.

### Consul

Consul представляет из себя один бинарный файл и любые приложения, использующие Consul, всегда выполняют запросы к нему на localhost:8500. Использование [Gossip](https://en.wikipedia.org/wiki/Gossip_protocol) в качестве протокола обмена данными делает Consul быстрым, отказоустойчивым и не требующим статическим образом выделенного мастера для нормального функционирования.

Consul может работать в режиме сервера или клиента. Клиентские инстансы Consul должны располагаться на каждом хосте, где есть использующие Consul приложения. Клиентские инстансы Consul называются агентами и в основном отвечают за переадресацию запросов Consul-серверам и за мониторинг своего хоста.

Описание *docker-compose.yml*:

```yaml
consul:
    hostname: consul
    container_name: consul
    image: consul:latest
    restart: always
    entrypoint:
      - consul
      - agent
      - -bind={{ GetInterfaceIP "eth0" }}
      - -client=0.0.0.0
      - -ui
      - -dev
# -dev option runs consul in development mode. Remove it and add following options to run consul in production.
#      - -server
#      - -bootstrap
#      - -data-dir=/data
# Consul doesn't need volume in development mode.
#    volumes:
#      - consul_volume:/data
    networks:
      - inner_network
    ports:
      - "8500:8500"
```

Необходимо обратить внимание на то, что в данном случае выбран запуск Consul в разработческом режиме, без сохранения данных на диск. В первую очередь это обусловлено багом взаимодействия Alpine-образов, на базе которого сделан официальный образ Consul, с файловой системой Windows Subsystem for Linux. При использовании volume в таком окружении Consul начинает себя вести очень странно, так как записи о ранее запущенных сервисах не удаляются и в списке сервисов Consul появляются зомби-процессы. Тем не менее, разработке отсутствие персистентности для Consul никак не мешает, а на Unix-машинах таких проблем возникать не должно и volume должен быть включён в конфигурации.

Как следует из конфигурации, Consul UI после запуска системы должен быть доступен на [http://localhost:8500](http://localhost:8500/). Другие сервисы при этом обращаются к Consul по адресу http://consul:8500 внутри сети **inner_network**.

Для использования Consul Service Discovery в зависимостях приложения необходимо указать:

```xml
<dependency>
	<groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-consul-discovery</artifactId>
</dependency>
```

Также необходимо указать аннотацию `@EnableDiscoveryClient(autoRegister = false)`:

```java
@SpringBootApplication
@EnableDiscoveryClient(autoRegister = false)
public class RentApplication {

    public static void main(String[] args) {
        SpringApplication.run(RentApplication.class, args);
    }
}
```

В аннотации указывается autoRegister = false, поскольку сами приложения регистрироваться не должны - их зарегистрирует
внешний регистрирующий сервис Gliderlabs Registrator.

### Gliderlabs Registrator
Проблема использования Consul для обнаружения сервисов в докер-контейнерах заключается в том, что сами сервисы не могут зарегистрироваться в Consul, так как порт приложения внутри докер-контейнера в общем случае отличается от порта, на котором приложение доступно извне. Особенно ярко это проявляется это при динамическом назначении портов при масштабировании сервисов. Для решения этой проблемы необходимо использовать какой-то вариант внешнего регистратора. [Gliderlabs Registrator](https://gliderlabs.github.io/registrator/latest/) автоматически регистрирует и разрегистрирует сервисы докер-контейнеров по мере их появления и исчезновения. Важным плюсом использования внешнего регистратора является то, что таким образом в Consul может быть зарегистрирован любой сервис, а не только приложение на базе Spring Boot.

*docker-compose.yml* описание сервиса:

```yaml
registrator:
    container_name: registrator
    command: -cleanup -internal consul://consul:8500
    privileged: true
    image: gliderlabs/registrator:latest
    restart: always
    depends_on:
      - consul
    volumes:
      - /var/run/docker.sock:/tmp/docker.sock
    networks:
      - inner_network
```

### Параметры запуска кластера

``` yaml
version: "3.7"

networks:
  default_overlay_network:
    external: true

volumes:
  consul:
  redis_data:
  elastic_data:
  grafana_volume:

services:       
###################################################################################

  consul_server:
    image: consul:1.17.2
    volumes:
      - consul:/consul
    ports:
      - target: 8500
        published: 8500
        mode: host
    networks:
      default_overlay_network:
        aliases:
          - consul
          - consul.cluster
    environment:
      - 'CONSUL_LOCAL_CONFIG={ "skip_leave_on_interrupt": true, "data_dir":"/consul/data", "server":true }'
      - CONSUL_BIND_INTERFACE=eth0 
    command: agent -ui -data-dir /consul/data -server -client 0.0.0.0 -bootstrap-expect=3 -retry-join consul.cluster
    deploy:
      endpoint_mode: dnsrr
      replicas: 3
      restart_policy:
        condition: any
        delay: 5s
        max_attempts: 10
        window: 120s
      placement:
        constraints: [node.role ==  manager]
###################################################################################

  consul_agent:
    image: consul:1.17.2
    volumes:
      - consul:/consul
    ports:
      - target: 8500
        published: 8500
        mode: host
    networks:
      default_overlay_network:
        aliases:
          - consul
    environment:
      - 'CONSUL_LOCAL_CONFIG={ "skip_leave_on_interrupt": true, "data_dir":"/consul/data"}'
      - CONSUL_BIND_INTERFACE=eth0 
    command: agent -ui -data-dir /consul/data -client 0.0.0.0 -retry-join consul.cluster
    deploy:
      endpoint_mode: dnsrr
      placement:
        constraints: [node.role !=  manager]      
      replicas: 4
      restart_policy:
        condition: any
        delay: 5s
        max_attempts: 10
        window: 120s
```