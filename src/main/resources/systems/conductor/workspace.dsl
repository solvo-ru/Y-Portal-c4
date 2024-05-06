workspace extends ../../solvo-landscape.dsl {

    name "Архитектура Оркестратора"
    description ""

    !impliedRelationships true
    !identifiers hierarchical

    configuration {        
        visibility public
        scope softwaresystem
        users {
            moarse write
            guest read
        }
    }

    model {
        lowcoder = person "Лоукодер" " " "Analyst"

        !extend bpm {
            Group FrontEnd {
                modeler = container "Process Modeler"   {                
                    description "Приложение для моделирования бизнес-процессов"
                    technology bpmn.io
                    tags  window 
                    perspectives {
                        "Security" "Ролевая модель доступа"
                        "Performance" "Отзывчивый UI"
                        "Scalability" "Support for large diagrams"
                        "Availability" "99.9% времени доступности"
                    }
                }
                
                optimize = container "Optimize" {
                    tags browser
                    description "Инструмент аналитики и мониторинга процессов"
                    perspectives {
                        "Security" "Ролевая модель доступа"
                        "Performance" "Эффективная агрегация и визуализация данных"
                        "Scalability" "Масштабируемость для больших данных"
                        "Availability" "Высокая доступность кластеризацией"
                    }
                    
                }

                tasklist = container "Tasklist" {
                    tags browser
                    description "Веб-приложение управления задачами"
                    perspectives {
                        "Security" "Ролевая модель доступа"
                        "Performance" "Отзывчивый UI управления задачами"
                        "Scalability" "Поддержка больших баз пользователей"
                        "Availability" "Высокая доступность  кластеризацией"
                    }
                }


                operate = container "Operate" {
                    tags browser
                    url https://docs.camunda.io/docs/self-managed/operate-deployment/operate-configuration/
                    description "Операционная панель управления и мониторинга бизнес-процессов"
                    perspectives {
                        "Security" "Ролевая модель доступа"
                        "Performance" "Мониторинг процессов в реальном времени"
                        "Scalability" "Масштабируемость для больших данных"
                        "Availability" "Высокая доступность кластеризацией"
                    }
                }
            }
            
            identity = container "Identity" {
                tags browser
                //description "Identity management component for Camunda"
                perspectives {
                    "Security" "Аутентификация и авторизация"
                    "Performance" "Эффективное идентификация"
                    "Scalability" "Масштабируемость для больших баз пользователей"
                    "Availability" "Высокая доступность кластеризацией"
                }
                -> iam "Идентификация" "JWT" "auth"
            }

            zeebe = container "BPM Engine" {
                !docs docs/zeebe 
                description "Оркестратор микросервисов"
                technology "Zeebe"
                perspectives {
                    "Security" "Ролевая модель доступа"
                    "Performance" "Эффективное выполнение рабочих процессов"
                    "Scalability" "Горизонтальное масштабирование для высокой пропускной способности"
                    "Availability" "Высокая доступность кластеризацией"
                }
                broker = component "Zeebe Broker" "Движок бизнес-процессов" "Zeebe" {
                    perspectives {
                        "Security" "Аутентификация и авторизация"
                        "Performance" "Эффективная оркестрация микросервисов"
                        "Scalability" "Эластичное масштабирование для высокой пропускной способности"
                        "Availability" "Высокая доступность репликацией"
                    }
                    -> broker "запуск подпроцессов" "Call Activity" "BPMN"
                }
                gateway = component "Zeebe Gateway" {
                    description "Шлюз API управляющий доступом к Zeebe  кластеру"
                    perspectives {
                        "Security" "Аутентификация и авторизация"
                        "Performance" "Эффективная маршрутизация запросов"
                        "Scalability" "Горизонтальное масштабирование для высокой пропускной способности"
                        "Availability" "Высокая доступность кластеризацией"
                    }
                    -> broker "Маршрутизация к движку"
                    -> identity "проверяет доступ" "JWT" "access"
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
                localMQ = component "Локальная очередь" {
                    -> queue 
                }
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
            zeebe.broker -> connectors "использует" "gRPC" "gRPC"
            zeebe.broker -> elastic "хранит данные"
            optimize -> zeebe.gateway "транслирует запрос" "gRPC" "gRPC"
            tasklist -> zeebe.gateway "транслирует запрос" "gRPC" "gRPC"
            operate -> zeebe.gateway "транслирует запрос" "gRPC" "gRPC"            
            modeler -> zeebe.gateway "deploy" "gRPC" "gRPC"
        }

    }
    views {

        component bpm.zeebe camunda-arch "Компоненты оркеcтратора" {
            include *
            include queue

        }
    }
}