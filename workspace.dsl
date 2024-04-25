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
        !include external.pdsl
         
        router = person "Логист" " " 
        dispatcher = person "Экспедитор" ""
        transport = person "Водитель" ""
        lowcoder = person "Лоукодер" " " "Analyst"
    

        webPortal = softwareSystem "Web-портал" "Доступ ко функциям системы через браузер" {
            tags "browser"  
            perspectives {
                "Security" "TLS/SSL шифрование"
                "Performance" "Быстрая загрузка"
                "Scalability" "Горизонтальное масштабирование балансировщиком нагрузки"
                "Availability" "Высокая доступность с отказоустойчивостью"
                "Regulatory/Compliance" "Соответствует требованиям GDPR"
            }
        }
            
        carrierApp = softwareSystem "Carrier App" "Мобильное приложение перевозчиков"  {
            tags "mobile" 
            perspectives {
                "Security" "Биометрическая аутентификация"
                "Scalability" "Поддержка большого количества одновременных пользователей"
                "Availability" "Синхронизация с сервером при наличии подключения"
            }
        }
            
        processModeler = softwareSystem "Process Modeler" "Приложение для моделирования бизнес-процессов"  {
            tags "bpmn.io" "browser" "infra"
            perspectives {
                "Security" "Ролевая модель доступа"
                "Performance" "Отзывчивый UI"
                "Scalability" "Support for large diagrams"
                "Availability" "99.9% времени доступности"
            }
        }

        publicApi = element "Public API" "Публичный API Портала"  {
            tags "REST" "OpenAPI" "infra"
            perspectives {
                "Security" "OAuth 2.0"
                "Performance" "Низкая задержка"
                "Scalability" "Версионирование API"
                "Availability" "99.99% времени доступности"
            }
        }

        yPortal = softwareSystem "Портал перевозчика"   {
            !include cloud.pdsl
            description "Система управления заявками на перевозку"
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
                !include camunda.pdsl
            }

            trWorker = container "Request"  {
                !include worker-dummy.pdsl
            }

            offerWorker = container "Offer"  {
                !include worker-dummy.pdsl
            }

            actorWorker = container  "Actor"  {
                !include worker-dummy.pdsl
            }

            roleWorker = container  "Role" {
                !include worker-dummy.pdsl
            }

            messageWorker = container  "Notifier"  {
                !include worker-dummy.pdsl
            }

            referenceWorker = container  "Refs" {
                !include worker-dummy.pdsl
            }

            shipmentWorker = container  "Shipment"  {
                !include worker-dummy.pdsl
            }


            keycloak = container "Keycloak" {
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

 
        }
        ext = softwareSystem "Интеграции" {
            tags "external" "abstract" "Queue"
            perspectives {
                "Integration" "Передача данных в реальном времени"
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
        apiGateway -> zeebeGateway "" "gRPC" "gRPC"
        apiGateway -> tasklist "управление процессами" "HTTP REST/JSON" "HTTP"
        apiGateway -> operate "техподдержка" "HTTP REST/JSON" "HTTP"
        apiGateway -> optimize "администрирование" "HTTP REST/JSON" "HTTP"
        router -> webPortal "Использует"
        lowcoder -> processModeler "Использует"  
        dispatcher -> carrierApp "Использует"
        dispatcher -> webPortal "Использует"
        transport -> carrierApp "Использует"

        webPortal -> apiGateway "Отправляет запрос" "HTTPS REST/JSON" "HTTP"
        carrierApp -> apiGateway "Отправляет запрос" "HTTPS REST/JSON" "HTTP"
        processModeler -> apiGateway "Отправляет запрос"
        //publicApi -> apiGateway "Отправляет запрос"
        identity -> keycloak ""
        trWorker -> zeebe "Long polling" "gRPC" "gRPC"
        offerWorker -> zeebe  "Long polling" "gRPC" "gRPC"
        actorWorker -> zeebe  "Long polling" "gRPC" "gRPC"
        roleWorker  -> zeebe "Long polling" "gRPC" "gRPC"
        messageWorker  -> zeebe  "Long polling" "gRPC" "gRPC"
        referenceWorker -> zeebe  "Long polling" "gRPC" "gRPC"
        shipmentWorker  -> zeebe "Long polling" "gRPC" "gRPC"

        connectors -> ext "внешние запросы" 
        zeebe -> yms "Создает автовизит"
        referenceWorker -> mdm "НСИ sync"
        referenceWorker -> erp "доступность ресурсов"
        webPortal -> tms "Отслеживание транспорта"
        keycloak -> idm " "
        keycloak -> ams " "
        keycloak -> roleWorker "get roles" "HTTP REST/JSON" "HTTP, GET, leap"
        messageWorker -> ext "notify" "" "async"
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
            exclude "element.tag==external && element.tag!=abstract"
            exclude "element.tag==infra"
            exclude "element.tag==db"
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