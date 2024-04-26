workspace extends ../../solvo-landscape.dsl {

    name "Архитектура Оркестратора"
    description ""

    //!impliedRelationships true
    !identifiers hierarchical

    configuration {
        visibility public
        scope softwaresystem
        users {
            moarse write
        }
    }

    model {
        lowcoder = person "Лоукодер" " " "Analyst"

        !extend bpm {
            Group FrontEnd {
                modeler = container "Process Modeler" "Приложение для моделирования бизнес-процессов"  {
                    tags "bpmn.io" "browser" "infra"
                    perspectives {
                        "Security" "Ролевая модель доступа"
                        "Performance" "Отзывчивый UI"
                        "Scalability" "Support for large diagrams"
                        "Availability" "99.9% времени доступности"
                    }
                }
                identity = container "Identity" {
                    tags "Camunda"
                    //description "Identity management component for Camunda"
                    perspectives {
                        "Security" "Аутентификация и авторизация"
                        "Performance" "Эффективное идентификация"
                        "Scalability" "Масштабируемость для больших баз пользователей"
                        "Availability" "Высокая доступность кластеризацией"
                    }

                }
                optimize = container "Optimize" {
                    tags "Camunda" "API"
                    //description "Инструмент аналитики и мониторинга процессов"
                    perspectives {
                        "Security" "Ролевая модель доступа"
                        "Performance" "Эффективная агрегация и визуализация данных"
                        "Scalability" "Масштабируемость для больших данных"
                        "Availability" "Высокая доступность кластеризацией"
                    }
                    
                }

                tasklist = container "Tasklist" {
                    tags "Camunda" "API"
                    //description "Веб-приложение управления задачами"
                    perspectives {
                        "Security" "Ролевая модель доступа"
                        "Performance" "Отзывчивый UI управления задачами"
                        "Scalability" "Поддержка больших баз пользователей"
                        "Availability" "Высокая доступность  кластеризацией"
                    }
                }


                operate = container "Operate" {
                    tags "Camunda" "API"
                    url https://docs.camunda.io/docs/self-managed/operate-deployment/operate-configuration/
                    //description "Операционная панель управления и мониторинга кластеров Camunda"
                    perspectives {
                        "Security" "Ролевая модель доступа"
                        "Performance" "Мониторинг процессов в реальном времени"
                        "Scalability" "Масштабируемость для больших данных"
                        "Availability" "Высокая доступность кластеризацией"
                    }
                }
            }


            zeebe = container "BPM Engine" {

                description "Оркестратор микросервисов"
                technology "Zeebe"
                tags "Orchestrator, Camunda"
                perspectives {
                    "Security" "Ролевая модель доступа"
                    "Performance" "Эффективное выполнение рабочих процессов"
                    "Scalability" "Горизонтальное масштабирование для высокой пропускной способности"
                    "Availability" "Высокая доступность кластеризацией"
                }
                broker = component "Zeebe Broker" "Движок бизнес-процессов" "Zeebe  " {
                    perspectives {
                        "Security" "Аутентификация и авторизация"
                        "Performance" "Эффективная оркестрация микросервисов"
                        "Scalability" "Эластичное масштабирование для высокой пропускной способности"
                        "Availability" "Высокая доступность репликацией"
                    }
                }
                gateway = component "Zeebe Gateway" {
                    description "Шлюз API управляющий доступом к Zeebe  кластеру"
                    perspectives {
                        "Security" "Аутентификация и авторизация"
                        "Performance" "Эффективная маршрутизация запросов"
                        "Scalability" "Горизонтальное масштабирование для высокой пропускной способности"
                        "Availability" "Высокая доступность кластеризацией"
                    }
                }
            }

            connectors = container "Connectors" {
                tags "Camunda"
                description "Интеграционные коннекторы"
                perspectives {
                    "Security" "Безопасная передача данных"
                    "Performance" "Эффективная передача данных"
                    "Scalability" "Поддержка различных сценариев интеграции"
                    "Availability" "Высокая доступность с отказоустойчивостью"
                }
                // -> ext "внешние запросы"
            }

            elastic = container "Хранилище процессов" {
                tags "elk" "db"
                description "Озеро данных"
                technology "Elasticsearch"
                perspectives {
                    "Security" "Ролевая модель доступа"
                    "Performance" "Высокоскоростной поиск и извлечение данных"
                    "Scalability" "Эластичная масштабируемость для больших наборов данных"
                    "Availability" "Высокая доступность  кластеризацией"

                }
            }
            zeebe -> connectors ""
            optimize -> zeebe "транслирует" "gRPC" "gRPC"
            tasklist -> zeebe "транслирует" "gRPC" "gRPC"
            operate -> zeebe "транслирует" "gRPC" "gRPC"
        }

    }
    views {
        systemContext
        
    }
}