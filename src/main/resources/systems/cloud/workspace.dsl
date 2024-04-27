workspace extends ../../solvo-landscape.dsl {

    name "Компоненты облачной инфраструктуры"
    description ""

    !impliedRelationships true
    !identifiers hierarchical

    configuration {
        visibility public
        scope softwaresystem
        users {
            moarse write
        }
    }

    model {

        !extend cloud {
            consul = container "Consul" "Сервис конфигурации и обнаружения" " " "Spring Cloud, Consul" {
                tags "infra" "Spring Cloud"
                perspectives {
                    "Security" "Шифрование транспортного уровня"
                    "Performance" "Высокомасштабируемое"
                    "Scalability" "Поддержка большого количества сервисов"
                    "Availability" "Высокая доступность с отказоустойчивостью"
                }
            }

            filebeat = container "Коллектор логов" {
                technology "Filebeat"
                tags "elk" "infra"
                description "Log shipper for forwarding logs"
                perspectives {
                    "Security" "Передача зашифрованных логов"
                    "Performance" "Малоизбыточность"
                    "Scalability" "Эластичная масштабируемость"
                    "Availability" "Высокая доступность с отказоустойчивостью"
                }
            }

            logstash = container "Обработчик логов" {
                technology "Logstash"
                tags "elk" "infra"
                perspectives {
                    "Security" "Шифрование данных"
                    "Performance" "Параллельная обработка"
                    "Scalability" "Горизонтально масштабируемое"
                    "Availability" "Отказоустойчивость кластеризацией"
                }
            }

            elastic = container "Хранилище логов" {
                technology "Elasticsearch"
                tags "elk" "infra" "db"
                perspectives {
                    "Security" "Ролевая модель доступа"
                    "Performance" "Почти реальное время инлдексации"
                    "Scalability" "Эластичная масштабируемость"
                    "Availability" "Высокая доступность  репликацией"
                }
            }

            zipkin = container "Zipkin" "Cистема распределенной трассировки" " " {
                tags "infra" "Spring Cloud"
                perspectives {
                    "Security" "Зашифрованное взаимодействие"
                    "Performance" "Малоизбыточность"
                    "Scalability" "Горизонтально масштабируемое"
                    "Availability" "Отказоустойчивость репликацией"
                }
            }

            git2consul = container "git2consul" "Синхронизация конфигураций из Git в Consul" " " {
                tags "infra" "Spring Cloud"
                perspectives {
                    "Security" "Зашифрованное взаимодействие"
                    "Performance" "Эффективная синхронизация"
                    "Scalability" "Горизонтальное масштабирование"
                    "Availability" "Высокая доступность с отказоустойчивостью"
                }
            }

            prometheus = container "Prometheus" "Система мониторинга и сбора метрик" " " {
                tags "infra"
                perspectives {
                    "Security" "Аутентификация и авторизация"
                    "Performance" "Низкозатратное инструментирование"
                    "Scalability" "Масштабируемость для больших сред"
                    "Availability" "Высокая доступность кластеризацией"
                }
            }

            grafana = container "Grafana" "Система мониторинга и визуализации метрик" " " {
                tags "Graphana" "infra"
                perspectives {
                    "Security" "Ролевая модель доступа"
                    "Performance" "Интерактивный дэщборд"
                    "Scalability" "Горизонтальное масштабирование"
                    "Availability" "Высокая доступность кластеризацией"
                }
            }

            kibana = container "Kibana" "Система визуализации и управления Elasticsearch" " " {
                tags "elk" "infra" "Kibana"
                perspectives {
                    "Security" "Ролевая модель доступа"
                    "Performance" "Почти реальное время индексации"
                    "Scalability" "Эластичная масштабируемость"
                    "Availability" "Высокая доступность репликацией"
                }
            }
        }
    }

    views {
        container cloud cloud-infra "Компоненты микросервисной инфраструктуры" {
            include *
        }
    }
}