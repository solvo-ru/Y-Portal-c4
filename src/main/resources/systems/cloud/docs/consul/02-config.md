## Распределенная конфигурация

Это понятие означает возможность хранить конфигурацию приложений централизовано, а не в виде отдельных файлов *application.yml*, разбросанных по множеству серверов, что гораздо удобнее. Реализация на базе **Spring Cloud Consul** позволяет хранить конфигурацию в **Consul KV Store**, а использование приложения [Git2consul](https://github.com/breser/git2consul) позволяет хранить конфигурацию в git-репозитории и передавать обновлённые версии в Consul KV Store по мере поступления изменений.

Для использования **Spring Cloud Consul Config** необходимо подключить зависимость

```xml
<dependency>
	<groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-consul-config</artifactId>
</dependency>
```

и перенести настройки Consul Config и название приложения из файла *application.yml* в файл *bootstrap.yml*, который Spring загружает на более раннем этапе запуска приложения:

```yaml
spring:
  application:
    name: ticket
  profiles:
    active: development
  cloud:
    consul:
      host: consul
      port: 8500
      config:
        enabled: true
        format: files
```

После этого можно будет получать параметры из **Consul KV Store**, хранящиеся там в соответствии с выбранным в настройках форматом.

Для автоматического обновления конфигурации в приложении можно воспользоваться аннотацией `@RefreshScope`. Все бины, помеченные аннотацией `@RefreshScope`, автоматически обновляются после изменения конфигурации.

```java
@RefreshScope
@SpringBootApplication
@EnableDiscoveryClient
public class HunterApplication {

    public static void main(String... args) {
        ConfigurableApplicationContext c = SpringApplication.run(HunterApplication.class, args);
    }
}
```

Настройки докер-контейнера Consul в файле *docker-compose.yml* описаны в разделе [Service Discovery](https://structurizr.kbinform.ru/workspace/2/documentation/Hunt/Consul#service-discovery)

Для загрузки настроек из git-репозитория используется приложение Git2consul. *docker-compose.yml* описание сервиса:

```yaml
git2consul:
    image: cimpress/git2consul
    depends_on:
      - consul
    volumes:
      - ./config/git2consul:/config
    command: --endpoint consul --config-file /config/git2consul.json
    networks:
      - inner_network
```

Настройки Git2consul находятся в файле *config/git2consul/git2consul.json*:

```json
{
  "version": "1.0",
  "local_store": "/var/lib/git2consul_cache",
  "logger" : {
    "name" : "git2consul",
    "streams" : [{
      "level": "trace",
      "stream": "process.stdout"
    },
      {
        "level": "debug",
        "type": "rotating-file",
        "path": "/var/log/git2consul/git2consul.log"
      }]
  },
  "repos" : [{
    "name" : "config",
    "url" : "https://github.com/moarsoarse/hunt-prototype-archive",
    "branches" : ["master"],
    "include_branch_name" : false,
    "source_root": "config/applications",
    "hooks": [{
      "type" : "polling",
      "interval" : "1"
    }]
  }]
}
```

В списке репозиториев url репозитория должен быть заменён на url персонального репозитория разработчика