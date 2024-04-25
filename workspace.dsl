 workspace {    

    name "Системная Архитектура Портала Перевозчика"
    description "[Camunda Edition]"

    !impliedRelationships true 

    configuration {
        visibility public
        scope softwaresystem
        users {
            moarse write
        }
    }

    model {
         
        router = person "Логист" " " 
        dispatcher = person "Экспедитор" ""
        transport = person "Водитель" ""
        lowcoder = person "Лоукодер" " " "Analyst"
    

        webPortal = softwareSystem "Web-портал" "Доступ ко всем функциям системы через браузер" {
            tags "browser"  "solvo" 
            perspectives {
                "Security" "TLS/SSL шифрование"
                "Performance" "Быстрая загрузка"
                "Scalability" "Горизонтальное масштабирование балансировщиком нагрузки"
                "Availability" "Высокая доступность с отказоустойчивостью"
                "Regulatory/Compliance" "Соответствует требованиям GDPR"
            }
        }
            
        carrierApp = softwareSystem "Carrier App" "Мобильное приложение перевозчиков"  {
            tags "mobile" "solvo"
            perspectives {
                "Security" "Биометрическая аутентификация"
                "Scalability" "Поддержка большого количества одновременных пользователей"
                "Availability" "Синхронизация с сервером при наличии подключения"
            }
        }
            
        processModeler = softwareSystem "Process Modeler" "Приложение для моделирования бизнес-процессов"  {
            tags "bpmn.io" "browser"
            perspectives {
                "Security" "Ролевая модель доступа"
                "Performance" "Отзывчивый UI"
                "Scalability" "Support for large diagrams"
                "Availability" "99.9% времени доступности"
            }
        }

        publicApi = element "Public API" "Публичный API Y-Portal"  {
            tags "REST" "OpenAPI" "solvo"
            perspectives {
                "Security" "OAuth 2.0"
                "Performance" "Низкая задержка"
                "Scalability" "Версионирование API"
                "Availability" "99.99% времени доступности"
            }
        }

        yPortal = softwareSystem "Y-PORTAL"   {
            description "Система управления заявками на перевозку"
            tags "solvo"
            apiGateway = container "API Gateway"   {
                technology "Spring Cloud Gateway" 
                description "Шлюз API для маршрутизации запросов"
                tags "Orchestrator" "Spring Cloud"
                perspectives {
                    "Security" "Защита от DDoS атак"
                    "Performance" "Кэширование для часто используемых эндпоинтов"
                    "Scalability" "Горизонтальное масштабирование балансировщиком нагрузки"
                    "Availability" "Активно-активная конфигурация для отказоустойчивости"
                }
            }
                       
            Group "Camunda Platform" {
            zeebe = container "Оркестратор микросервисов" {
                description "Движок бизнес-процессов"
                technology "Zeebe Engine"
                tags  "Orchestrator, Camunda"                
                perspectives {
                    "Security" "Ролевая модель доступа"
                    "Performance" "Эффективное выполнение рабочих процессов"
                    "Scalability" "Горизонтальное масштабирование для высокой пропускной способности"
                    "Availability" "Высокая доступность кластеризацией"
                }

                component "Zeebe Broker" "Движок бизнес-процессов" "Zeebe"{
                    perspectives {
                        "Security" "Аутентификация и авторизация"
                        "Performance" "Эффективная оркестрация микросервисов"
                        "Scalability" "Эластичное масштабирование для высокой пропускной способности"
                        "Availability" "Высокая доступность репликацией"
                    }
                }

                component "Zeebe Gateway" {
                    description "Шлюз API управляющий доступом к Zeebe  кластеру"
                    perspectives {
                        "Security" "Аутентификация и авторизация"
                        "Performance" "Эффективная маршрутизация запросов"
                        "Scalability" "Горизонтальное масштабирование для высокой пропускной способности"
                        "Availability" "Высокая доступность кластеризацией"
                    }  
                }

            }

            optimize = container "Optimize" {
                tags "Camunda"
                description "Инструмент аналитики и мониторинга процессов"
                perspectives {
                    "Security" "Ролевая модель доступа"
                    "Performance" "Эффективная агрегация и визуализация данных"
                    "Scalability" "Масштабируемость для больших данных"
                    "Availability" "Высокая доступность кластеризацией"
                }
            }

            identity = container "Identity" {
                tags "Camunda"
                description "Identity management component for Camunda"
                perspectives {
                    "Security" "Аутентификация и авторизация"
                    "Performance" "Эффективное идентификация"
                    "Scalability" "Масштабируемость для больших баз пользователей"
                    "Availability" "Высокая доступность кластеризацией"
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
    
            }
            
            operate = container "Operate" {    
                tags "Camunda"
                description "Операционная панель управления и мониторинга кластеров Camunda"
                perspectives {
                    "Security" "Ролевая модель доступа"
                    "Performance" "Мониторинг процессов в реальном времени"
                    "Scalability" "Масштабируемость для больших данных"
                    "Availability" "Высокая доступность кластеризацией"
                }
            }

            tasklist = container "Tasklist" {
                tags "Camunda"
                description "Веб-приложение управления задачами"
                perspectives {
                    "Security" "Ролевая модель доступа"
                    "Performance" "Отзывчивый UI управления задачами"
                    "Scalability" "Поддержка больших баз пользователей"
                    "Availability" "Высокая доступность  кластеризацией"
                }
            }

            elasticZeebe =  container "Хранилище процессов" {
                tags "elk"
                description "Озеро данных"
                technology "Elasticsearch"
                perspectives {
                    "Security" "Ролевая модель доступа"
                    "Performance" "Высокоскоростной поиск и извлечение данных"
                    "Scalability" "Эластичная масштабируемость для больших наборов данных"
                    "Availability" "Высокая доступность  кластеризацией"
                }
            }
            }

            Group "Workers" {
                trWorker = container "Воркер заявки на перевозку"  {
                    !include worker-dummy.pdsl
                }

                offerWorker = container "Воркер предложения"  {
                    !include worker-dummy.pdsl
                }

                actorWorker = container  "Воркер участника"  {
                    !include worker-dummy.pdsl
                }

                userWorker = container  "Воркер пользователя" {
                    !include worker-dummy.pdsl
                }

                messageWorker = container  "Воркер уведомлений"  {
                    !include worker-dummy.pdsl
                }

                referenceWorker = container  "Воркер ссылок" {
                    !include worker-dummy.pdsl
                }

                shipmentWorker = container  "Воркер перевозки"  {
                    !include worker-dummy.pdsl
                }
            }

            container "Keycloak" {
                description "Управление аутентификацией и авторизацией"
                tags "Keycloak"
                perspectives {
                    "Security" "OAuth 2.0 authentication"
                    "Performance" "Масштабируемость для больших баз пользователей"
                    "Scalability" "Горизонтальное масштабирование для высокой пропускной способности"
                    "Availability" "Высокая доступность кластеризацией"
                }
            }

            /***
            etl = container "ETL" "Инструмент интеграции данных путем трансформации" "Apache Nifi" {
                perspectives {
                    "Security" "Шифрованная передача данных"
                    "Performance" "Масштабируемая обработка данных"
                    "Scalability" "Горизонтальное масштабирование"
                    "Availability" "Высокая доступность с кластеризацией"
                }
            }
        
            messageQueue = container "Apache Kafka" "Очередь сообщений для асинхронной связи между микросервисами" "Kafka" "Queue" {
                perspectives {
                    "Security" "SSL шифрование"
                    "Performance" "Высокая пропускная способность"
                    "Scalability" "Линейная масштабируемость"
                    "Availability" "Отказоустойчивость  репликацией"
                }
            }
           ***/ 


            //postgres = container "PostgreSQL" "БД для хранения постоянных данных" "PostgreSQL 16"
            //redis = container "Redis" "In-memory KV-хранилище" "Redis"

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
            logstash = container  "Обработчик логов" {
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
                tags "elk" "infra"
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
        }

        yms = softwareSystem "YMS" "Система управления транспортными дворами" "external" {
                  perspectives {
                "Integration" "Передача данных в реальном времени"
            }    
        }
        
        mdm = softwareSystem "MDM" "Система управления справочными данными" "external" {
            perspectives {
                "Integration" "Синхронизация по расписанию"
            }
        }
        

        erp = softwareSystem "ERP" "Система планирования ресурсов предприятия" "external" {
            perspectives {
                "Integration" "Двусторонний обмен"
            }
        }
        tms = softwareSystem "TMS" "Система управления транспортными операциями" "external" {
            perspectives {
                "Integration" "Передача данных в реальном времени"
            }
        }
        idm = softwareSystem "IDM" "Система идентификации пользователей" "external" {
            perspectives {
                "Integration" "SSO"
            }
        }

        ams = softwareSystem "AMS" "Система управления доступом пользователей" "external" {
            description "Access Management System for managing user access permissions"
            perspectives {
                "Integration" "Авторизация в реальном времени "
            }
        }


        // Development environment using Docker
        development = deploymentEnvironment "Development" {
            deploymentNode "Developer Machine" {
                infrastructureNode "Docker Engine" {
                    // softwareSystemInstance "yPortal" ""  ""{

                    //     // ...
                    // }
                    // containerInstance trWorker {
                    //     // ...
                    // }
                    // ... Other container instances
                }
            }
        }

        // Production environment using Kubernetes
        production = deploymentEnvironment "Production" {
            // deploymentGroup "Kubernetes Cluster" {
            //     deploymentNode "Kubernetes Master" {
            //         // ...
            //     }
            //     deploymentNode "Kubernetes Node" {
            //         // ...
            //         // containerInstance trWorker {
            //         //     // ...
            //         // }
            //         // ... Other container instances
            //     }
            // }
        }

        router -> webPortal "Использует"
        lowcoder -> processModeler "Использует"  
        dispatcher -> carrierApp "Использует"
        transport -> carrierApp "Использует"

        webPortal -> apiGateway "Отправляет запрос"
        carrierApp -> apiGateway "Отправляет запрос" 
        processModeler -> apiGateway "Отправляет запрос"
        publicApi -> apiGateway "Отправляет запрос"

        trWorker -> zeebe "Long polling" "gRPC"
        offerWorker -> zeebe  "Long polling" "gRPC"
        actorWorker -> zeebe  "Long polling" "gRPC"
        userWorker  -> zeebe "Long polling" "gRPC"
        messageWorker  -> zeebe  "Long polling" "gRPC"
        referenceWorker -> zeebe  "Long polling" "gRPC"
        shipmentWorker  -> zeebe "Long polling" "gRPC"

        zeebe -> yms "Создает автовизит"
        referenceWorker -> mdm "НСИ sync"
        connectors -> erp "Доступность ресурсов"
        webPortal -> tms "Отслеживание транспорта"
        identity -> idm " "
        identity -> ams " "
    }

    views {
        theme https://structurizr.moarse.ru/workspace/3/theme
        properties {
            "structurizr.timezone" "Europe/Moscow"
            "structurizr.locale" "en-GB"
        }


        systemContext yPortal  "yp-context" "Системный контекст Портала Перевозчика"  {
            include *

        }

        container yPortal "yp-structure" "Структура Портала Перевозчика" {
            include *
            exclude "element.tag==infra"
        }




        // deployment yPortal "Production" {
        //     include *
        //     autolayout lr
        // }

        // Dynamic diagram for Bidding Workflow
        // dynamic yPortal {
        //     webPortal -> trWorker "1. Create TR"
        //     trWorker -> offerWorker "2. Make a bid"
        //     offerWorker -> trWorker "3. Collect bids"
        //     trWorker -> trWorker "4. Choose winner"
        // }

        // // Dynamic diagram for Transporting Workflow
        // dynamic yPortal{
        //     webPortal -> shipmentWorker "1. Accept shipment"
        //     shipmentWorker -> shipmentWorker "2. Start shipment"
        //     shipmentWorker -> shipmentWorker "3. Visit point x"
        //     shipmentWorker -> shipmentWorker "4. Visit last point"
        //     shipmentWorker -> trWorker "5. Mark/star results"
        // }
       
    }
}