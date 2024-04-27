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
                    tags "browser"
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
                    tags "mobile"
                    perspectives {
                        "Security" "Биометрическая аутентификация"
                        "Scalability" "Поддержка большого количества одновременных пользователей"
                        "Availability" "Синхронизация с сервером при наличии подключения"
                    }
                    -> bpm "Запуск процессов, Выполнение userTask" "Gateway, Zeebe" "leap"
                }

                api = container "Public API" "Публичный API Портала" {
                    tags "REST" "OpenAPI" "infra"
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
                tags "Orchestrator" "Spring Cloud"
                perspectives {
                    "Security" "Защита от DDoS атак"
                    "Performance" "Кэширование для часто используемых эндпоинтов"
                    "Scalability" "Горизонтальное масштабирование балансировщиком нагрузки"
                    "Availability" "Активно-активная конфигурация для отказоустойчивости"
                }
            }

            Group BackEnd {

                trWorker = container "Request" {
                    !include ../../fragments/worker-dummy.pdsl
                    -> queue "Подписка" "" "async"
                }

                offerWorker = container "Offer" {
                    !include ../../fragments/worker-dummy.pdsl
                    -> queue "Подписка" "" "async"
                }

                actorWorker = container "Actor" {
                    !include ../../fragments/worker-dummy.pdsl
                }

                roleWorker = container "Role" {
                    !include ../../fragments/worker-dummy.pdsl
                }

                messageWorker = container "Notifier" {
                    !include ../../fragments/worker-dummy.pdsl
                    -> app "Оповещения" "SSE" ""
                }

                referenceWorker = container "Refs" {
                    !include ../../fragments/worker-dummy.pdsl
                }

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
        yPortal.apiGateway -> bpm "выполнение user tasks" "gRPC" "gRPC"
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
        yPortal.trWorker -> bpm "Получает задачи" "gRPC long polling" "gRPC"
        yPortal.offerWorker -> bpm "Получает задачи" "gRPC long polling" "gRPC"
        yPortal.actorWorker -> bpm "Получает задачи" "gRPC long polling" "gRPC"
        yPortal.roleWorker -> bpm "Получает задачи" "gRPC long polling" "gRPC"
        yPortal.messageWorker -> bpm "Получает задачи" "gRPC long polling" "gRPC"
        yPortal.referenceWorker -> bpm "Получает задачи" "gRPC long polling" "gRPC"
        yPortal.shipmentWorker -> bpm "Получает задачи" "gRPC long polling" "gRPC"

        
        bpm -> yms "Создает автовизит"
        yPortal.referenceWorker -> mdm "НСИ sync" " " " "
        yPortal.referenceWorker -> erp "доступность ресурсов"
        yPortal.web -> tms "Отслеживание транспорта"

        //iam -> roleWorker "get roles" "HTTP REST/JSON" "HTTP, GET, leap"
       // messageWorker -> ext "notify" "async"
    }

    views {
        systemContext yPortal "yp-context" "Системный контекст Портала Перевозчика" {
            include *
        }

        container yPortal "yp-structure" "Структура Портала Перевозчика" {
            include *
            // exclude "element.tag==external && element.tag!=abstract"
            // exclude "element.tag==infra"
            // exclude "element.tag==db"
        }

        // deployment yPortal "Production" {
        //     include *
        //     autolayout lr
        // }

        dynamic yPortal "yp-bidding" "Процесс заявки на перевозку" {
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
            bpm -> yPortal.offerWorker "Сохранить предложения"
            {
                {
                    yPortal.offerWorker -> queue "Отправляет сообщение в очередь"
                    queue -> yPortal.trWorker "Обновление ссылок"
                }
                {
                    yPortal.offerWorker -> bpm ""
                }
            }
            router -> bpm "Выбрать победителя"
            dispatcher -> bpm "Подтвердить выполнение"
            bpm -> queue "Автовизит"
           

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