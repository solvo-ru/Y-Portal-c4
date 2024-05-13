workspace extends ../../solvo-landscape.dsl {

    name "Архитектура Оркестратора"
    description ""

    !impliedRelationships true
    !identifiers flat

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
            properties {
                wiki.document.id TJ1T0ha2XI
            }
            Group FrontEnd {
                modeler = container "Process Modeler"   {                
                    description "Приложение для моделирования бизнес-процессов"
                    technology bpmn.io
                    tags  window Tool 
                    perspectives {
                        "Security" "Ролевая модель доступа"
                        "Performance" "Отзывчивый UI"
                        "Scalability" "Support for large diagrams"
                        "Availability" "99.9% времени доступности"
                    }
                }
                
                optimize = container "Optimize" {
                    tags browser Tool
                    description "Инструмент аналитики и мониторинга процессов"
                    perspectives {
                        "Security" "Ролевая модель доступа"
                        "Performance" "Эффективная агрегация и визуализация данных"
                        "Scalability" "Масштабируемость для больших данных"
                        "Availability" "Высокая доступность кластеризацией"
                    }
                    
                }

                tasklist = container "Tasklist" {
                    tags browser Tool
                    description "Веб-приложение управления задачами"
                    perspectives {
                        "Security" "Ролевая модель доступа"
                        "Performance" "Отзывчивый UI управления задачами"
                        "Scalability" "Поддержка больших баз пользователей"
                        "Availability" "Высокая доступность  кластеризацией"
                    }
                }


                operate = container "Operate" {
                    tags browser Tool
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
                tags browser Tool
                //description "Identity management component for Camunda"
                perspectives {
                    "Security" "Аутентификация и авторизация"
                    "Performance" "Эффективное идентификация"
                    "Scalability" "Масштабируемость для больших баз пользователей"
                    "Availability" "Высокая доступность кластеризацией"
                }
                -> iam "Идентификация" "JWT" "check, major, sync"
            }

             Group Zeebe {
                broker = container "Zeebe Broker" "Движок бизнес-процессов" "Zeebe" {
                    !docs docs/zeebe 
                    tags Pillar
                    description "Оркестратор микросервисов"
                    perspectives {
                        "Security" "Аутентификация и авторизация"
                        "Performance" "Эффективная оркестрация микросервисов"
                        "Scalability" "Эластичное масштабирование для высокой пропускной способности"
                        "Availability" "Высокая доступность репликацией"
                    }
                    -> broker "запуск подпроцессов" "Call Activity" "async, major, vague"
                }
                gateway = container "Zeebe Gateway" {
                    tags Tool
                    description "Шлюз API управляющий доступом к Zeebe  кластеру"
                    perspectives {
                        "Security" "Аутентификация и авторизация"
                        "Performance" "Эффективная маршрутизация запросов"
                        "Scalability" "Горизонтальное масштабирование для высокой пропускной способности"
                        "Availability" "Высокая доступность кластеризацией"
                    }
                    -> broker "Маршрутизация к движку" "gRPC" "async, major, command"
                    -> identity "проверяет доступ" "JWT" "check, sync, major"
                }
            }
            connectors = container "Connectors" {
                tags Camunda Pillar
                description "Интеграционные коннекторы"
                perspectives {
                    "Security" "Безопасная передача данных"
                    "Performance" "Эффективная передача данных"
                    "Scalability" "Поддержка различных сценариев интеграции"
                    "Availability" "Высокая доступность с отказоустойчивостью"
                }
                localMQ = component "Локальная очередь" {
                    -> queue "" "AMQP" "async, major, message"
                }
            }

            elastic = container "Озеро данных" {
                tags ELK db
                technology Elasticsearch
                perspectives {
                    "Security" "Ролевая модель доступа"
                    "Performance" "Высокоскоростной поиск и извлечение данных"
                    "Scalability" "Эластичная масштабируемость для больших наборов данных"
                    "Availability" "Высокая доступность  кластеризацией"
                }
            }
            broker -> connectors "использует" "gRPC" "async, major, request"
            connectors -> yms  "Автовизит" "REST" "sync, aux, message"
            broker -> elastic "хранит данные" "HTTP" "safe, sync, major"
            optimize -> gateway "транслирует запрос" "gRPC" "sync, aux, request"
            tasklist -> gateway "транслирует запрос" "gRPC" "sync, major, command"
            operate -> gateway "транслирует запрос" "gRPC" "sync, aux, request"            
            modeler -> gateway "deploy" "gRPC" "sync, major, request"
            yPortal -> gateway "Запуск процессов" "gRPC" "async, major, leap, command"
            yPortal -> tasklist "Выполнение задач" "HTTP" "sync, major, leap, command"
            lowcoder -> optimize "Оптимизация" "WWW" "aux, request"
            lowcoder -> operate "Поддержка" "WWW" "aux, request"
        
        !script ../../scripts/Tagger.groovy {             
                type system
            }
        
        }
        production = deploymentEnvironment "Production" {
            kuberNode1 = deploymentGroup kuberNode1
            kuberNode2 = deploymentGroup kuberNode2
            kuberNode3 = deploymentGroup kuberNode3
            kuberNode4 = deploymentGroup kuberNode4

            deploymentNode "Node A" "" "Kubernetes" "node" {
                deploymentNode Zeebe Pod "" "pod"{
                    deploymentNode BrokerContainer Docker "" "dock"{
                      containerInstance broker serviceInstance1 "deploy"
                    }
                    deploymentNode GatewayContainer Docker "" "dock"{
                      containerInstance gateway serviceInstance1 "ep"
                    }                    
                }
                deploymentNode Elastic Pod {
                    deploymentNode ElasticContainer Docker "" "dock" {
                      containerInstance elastic serviceInstance1 "pv"
                    }
                                    
                }
                deploymentNode TaskOperate Pod "" "pod" {
                    deploymentNode TasklistContainer Docker "" "dock"{
                      containerInstance tasklist serviceInstance1 "deploy"
                    }
                    deploymentNode OperateContainer Docker "" "dock"{
                      containerInstance operate serviceInstance1 "deploy"
                    }                    
                }
            }
            deploymentNode "Node B" "" "Kubernetes" "node"{
                deploymentNode Zeebe Pod "" "pod" {
                    deploymentNode BrokerContainer Docker "" "dock"{
                      containerInstance broker serviceInstance2 "deploy"
                    }
                    deploymentNode GatewayContainer Docker "" "dock"{
                      containerInstance gateway serviceInstance2 "ep"
                    }                    
                }
                deploymentNode Elastic Pod "" "pod" {
                    deploymentNode ElasticContainer Docker "" "dock"{
                      containerInstance elastic serviceInstance2 "pv"
                    }
                                    
                }
                deploymentNode TaskOperate Pod "" "pod" {
                    deploymentNode TasklistContainer Docker "" "dock" {
                      containerInstance tasklist serviceInstance2 "deploy"
                    }
                    deploymentNode OperateContainer Docker "" "dock" {
                      containerInstance operate serviceInstance2  "deploy"
                    }                    
                }
            }
            deploymentNode "Node C" "" "Kubernetes" "node"{
                deploymentNode Zeebe Pod "" "pod" {
                    deploymentNode BrokerContainer Docker "" "dock"  {
                      containerInstance broker serviceInstance3  "deploy"
                    }                                   
                }
                deploymentNode Key Pod "" "pod"{
                    deploymentNode KeyContainer Docker "" "dock" {
                      softwareSystemInstance iam serviceInstance3  "svc"
                    }
                                    
                }
                deploymentNode ID Pod "" "pod" {
                    deploymentNode IdContainer Docker "" "dock" {
                      containerInstance identity serviceInstance3  "deploy"
                    }
                                    
                }
            }
            deploymentNode "Node D" "" "Kubernetes" "node" {
                deploymentNode Integration Pod "" "pod"{
                    deploymentNode ConContainer Docker "" "dock" {
                      containerInstance connectors serviceInstance4 "deploy"
                    }                                   
                }
                deploymentNode Key Pod "" "pod" {
                    deploymentNode KeyContainer Docker "" "dock" {
                      softwareSystemInstance iam serviceInstance4 "svc"
                    }
                                    
                }
                deploymentNode ID Pod "" "pod"{
                    deploymentNode IdContainer Docker "" "dock" {
                      containerInstance identity serviceInstance4  "deploy"
                    }
                                    
                }
            }
            
        }

    }
    views {

        container bpm camunda-arch "Компоненты оркеcтратора" {
            include *
            include queue

        }
        deployment * production vendor-schema "Рекомендованная схема" {
            include *
            exclude relationship==*
        }
    }
}