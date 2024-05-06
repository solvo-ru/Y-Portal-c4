workspace extends ../../solvo-landscape.dsl {

    name "Системная Архитектура Портала Перевозчика"
    description "[Camunda Edition]"

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

        router = person "Логист" {
            -> bpm "Выполняет UserTask" "Zeebe" "leap"
        }
        dispatcher = person "Экспедитор" "" {
            -> bpm "Выполняет UserTask" "Zeebe" "leap"
        }
        transport = person "Водитель" "" {
            -> bpm "Выполняет UserTask" "Zeebe" "leap"
        }
       
        !extend yPortal {
            description "Система управления заявками на перевозку"

            Group FrontEnd {
                web = container "Web-портал" "Доступ ко функциям системы через браузер" {
                    tags "browser, solvo"
                    perspectives {
                        "Security" "TLS/SSL шифрование"
                        "Performance" "Быстрая загрузка"
                        "Scalability" "Горизонтальное масштабирование балансировщиком нагрузки"
                        "Availability" "Высокая доступность с отказоустойчивостью"
                        "Regulatory/Compliance" "Соответствует требованиям GDPR"
                    }
                    -> bpm "Запуск процессов, Выполнение userTask" "Gateway, Zeebe" "leap"
                }

                app = container "Carrier App" "Мобильное приложение перевозчиков" {
                    tags "mobile, solvo"
                    perspectives {
                        "Security" "Биометрическая аутентификация"
                        "Scalability" "Поддержка большого количества одновременных пользователей"
                        "Availability" "Синхронизация с сервером при наличии подключения"
                    }
                    -> bpm "Запуск процессов, Выполнение userTask" "Gateway, Zeebe" "leap"
                }

                api = container "Public API" "Публичный API Портала" {
                    tags REST OpenAPI infra
                    perspectives {
                        "Security" "OAuth 2.0"
                        "Performance" "Низкая задержка"
                        "Scalability" "Версионирование API"
                        "Availability" "99.99% времени доступности"
                    }
                }
            }

            apiGateway = container "API Gateway" {
                technology "Spring Cloud Gateway"
                description "Шлюз API для маршрутизации запросов"
                tags bus "Spring Cloud"
                perspectives {
                    "Security" "Защита от DDoS атак"
                    "Performance" "Кэширование для часто используемых эндпоинтов"
                    "Scalability" "Горизонтальное масштабирование балансировщиком нагрузки"
                    "Availability" "Активно-активная конфигурация для отказоустойчивости"
                }
            }

            Group BackEnd {

                trWorker = container "Request" {
                    !docs docs/request
                    description "Сервис заявок на перевозку" 
                    !include ../../fragments/worker-dummy.pdsl  
                }
                trDb = container "Request Database" {
                    technology "PostreSQL 16"
                    tags db Postgres 
                }
                trWorker.repo -> trDb "" "JDBC"

                offerWorker = container "Offer" { 
                    description "Сервис предложений"
                    !include ../../fragments/worker-dummy.pdsl
                }
                offerDb = container "Offer Database" {
                    technology "PostreSQL 16"
                    tags db Postgres 
                }
                offerWorker.repo -> offerDb "" "JDBC"

                actorWorker = container "Actor" {
                    description "Сервис участников процесса"
                    !include ../../fragments/worker-dummy.pdsl                   
                }

                roleWorker = container "Role" {
                    !include ../../fragments/worker-dummy.pdsl
                }

                messageWorker = container "Notifier" {
                    !include ../../fragments/worker-dummy.pdsl
                    -> app "Оповещения" "SSE" "async"
                }

                referenceWorker = container "Refs" {
                    !include ../../fragments/worker-dummy.pdsl
                }
                refDb = container "Master Data DB" {
                    technology "PostreSQL 16"
                    tags db Postgres 
                }
                referenceWorker.repo -> refDb "" "JDBC"

                shipmentWorker = container "Shipment" {
                    !include ../../fragments/worker-dummy.pdsl 
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


               ***/


                //postgres = container "PostgreSQL" "БД для хранения постоянных данных" "PostgreSQL 16"
                //redis = container "Redis" "In-memory KV-хранилище" "Redis"


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
        yPortal.apiGateway -> bpm "Запуск процессов, выполнение задач" "gRPC" "gRPC"
        // apiGateway -> tasklist "управление процессами" "HTTP REST/JSON" "HTTP"
        // apiGateway -> operate "техподдержка" "HTTP REST/JSON" "HTTP"
        // apiGateway -> optimize "администрирование" "HTTP REST/JSON" "HTTP"
        // apiGateway -> keycloak "проверяет токен" "JWT" "HTTP"
        router -> yPortal.web "Управляет заявками, отслеживает перевозки"
        dispatcher -> yPortal.app "Подтверждает перевозку"
        dispatcher -> yPortal.web "Вносит предложения"
        transport -> yPortal.app  "Отчитывается о перевозке"

        yPortal.web -> yPortal.apiGateway "Отправляет запрос" "HTTPS REST/JSON" "HTTP"
        yPortal.app -> yPortal.apiGateway "Отправляет запрос" "HTTPS REST/JSON" "HTTP"
        //publicApi -> apiGateway "Отправляет запрос"
        
        yPortal.web ->  iam "Доступ" "JWT" "auth"
        yPortal.app ->  iam "Доступ" "JWT" "auth"
        yPortal.apiGateway -> iam "" "JWT" "auth"
        bpm -> yms "Создает автовизит" 
        yPortal.web -> tms "Отслеживание транспорта" "HTTPS"

        //iam -> roleWorker "get roles" "HTTP REST/JSON" "HTTP, GET, leap"
       // messageWorker -> ext "notify" "async"
    }

    views {
        systemContext yPortal yp-context "Системный контекст Портала Перевозчика" {
            include *
            include queue->
            exclude relationship.tag==leap
            exclude "element.tag==db"
        }

        container yPortal yp-structure "Структура Портала Перевозчика" {
            include *
            exclude relationship.tag==leap
            // exclude "element.tag==external && element.tag!=abstract"
            // exclude "element.tag==infra"
            exclude "element.tag==db"
        }

        // deployment yPortal "Production" {
        //     include *
        //     autolayout lr
        // }
        component yPortal.trWorker request-structure "Компоненты микросервиса 'Заявка на перевозку'" {
            include *
            exclude bpm->*
        }


        dynamic yPortal yp-bidding "Процесс заявки на перевозку" {
            router -> yPortal.web "Создает заявку в web-форме" ""
            yPortal.web -> yPortal.apiGateway "Вызывает метод API"
            yPortal.apiGateway -> bpm "Маршрутизация на запуск процесса"
            bpm -> yPortal.trWorker "Сохранить заявку"
            yPortal.trWorker -> bpm "Вернуть ID"
            router -> bpm "Оформить заявку"
            bpm -> yPortal.trWorker "Обновить заявку"
            yPortal.trWorker -> bpm "ОК"
            bpm -> yPortal.messageWorker "Уведомление 'Новая заявка'"
            yPortal.messageWorker -> yPortal.app  "'Новая заявка'"
            yPortal.app -> dispatcher "Получает сообщение"
            dispatcher -> yPortal.web "Заполняет форму предложения"
            yPortal.web -> bpm "Запускает процесс 'Предложение'"
            bpm -> yPortal.offerWorker "Сохранить предложение"
            yPortal.offerWorker -> bpm "Вернуть ID"
            bpm -> bpm "Отправить сообщение в процесс заявки" 
            router -> bpm "Выбрать победителя"
            dispatcher -> bpm "Подтвердить выполнение"
            bpm -> yms "Создать автовизит" 
        }


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