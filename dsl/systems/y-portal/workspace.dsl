workspace extends ../../solvo-landscape.dsl {

    name "Системная Архитектура Портала Перевозчика"
    description "[Camunda Edition]"
    properties {
        wiki.document.id GKzQMcy43s

    }
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
            -> bpm "Выполняет UserTask" "Zeebe" "leap, command, major"
        }
        dispatcher = person "Экспедитор" "" {
            -> bpm "Выполняет UserTask" "Zeebe" "leap, command, major"
        }
        transport = person Водитель {
            tags doubt
            -> bpm "Выполняет UserTask" "Zeebe" "leap, message, major"
        }

        !extend yPortal {
            description "Система управления заявками на перевозку"
            properties {
                "wiki.document.id" Sl14kRICxJ
            }

            Group FrontEnd {
                web = container "Web-портал" "Доступ ко функциям системы через браузер" {

                    tags browser Solvo Product
                    perspectives {
                        "Security" "TLS/SSL шифрование"
                        "Performance" "Быстрая загрузка"
                        "Scalability" "Горизонтальное масштабирование балансировщиком нагрузки"
                        "Availability" "Высокая доступность с отказоустойчивостью"
                        "Regulatory/Compliance" "Соответствует требованиям GDPR"
                    }
                    //-> bpm "Запуск процессов, Выполнение userTask" "Gateway, Zeebe" "leap, command, major"
                }

                app = container "Carrier App" "Мобильное приложение перевозчиков" {
                    tags mobile Solvo Addon future
                    perspectives {
                        "Security" "Биометрическая аутентификация"
                        "Scalability" "Поддержка большого количества одновременных пользователей"
                        "Availability" "Синхронизация с сервером при наличии подключения"
                    }
                    //-> bpm "Запуск процессов, Выполнение userTask" "Gateway, Zeebe" "leap, message, major"
                }

                api = container "Public API" "Публичный API Портала" {
                    tags Addon future
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
                tags bus "Spring Cloud" Tool
                perspectives {
                    "Security" "Защита от DDoS атак"
                    "Performance" "Кэширование для часто используемых эндпоинтов"
                    "Scalability" "Горизонтальное масштабирование балансировщиком нагрузки"
                    "Availability" "Активно-активная конфигурация для отказоустойчивости"
                }
            }
            redis = container Redis {
                technology "KV-storage"
                description "Хранение сессий пользователей"
                tags Redis db Tool
            }
            apiGateway -> redis "Кэш" "" "aux, safe, sync"

            Group Cloud {
                !include ../../fragments/cloud.pdsl

            }
            apiGateway -> yPortal.consul "Регистрация, конфигурация" "DNS/HTTP" "aux, collect, safe"
            bpm -> yPortal.consul "Регистрация, конфигурация" "DNS/HTTP" "aux, collect, safe"

            Group BackEnd {
                requestWorker = container ShipmentRequest {
                    // !docs docs/request
                    properties {
                        wiki.document.id 6V4RDZuJnJ
                    }
                    description "Сервис заявок на перевозку"
                    !include ../../fragments/worker-dummy.pdsl
                }
                trDb = container RequestDB {
                    technology "PostreSQL 16"
                    tags db Postgres
                    request = component REQUEST "" Table "table"
                    requestSchema = component REQUEST_SCHEMA "" Table "table"
                    request -> requestSchema "schemaId" "FK" "vague"
                }
                requestWorker.repo -> trDb "" "JDBC" "safe, sync, major"

                offerWorker = container Offer {
                    description "Сервис предложений"
                    !include ../../fragments/worker-dummy.pdsl

                }
                offerDb = container "OfferDB" {
                    technology "PostreSQL 16"
                    tags db Postgres
                    offer = component OFFER "" Table "table"
                    offerSchema = component OFFER_SCHEMA "" Table "table"
                    offer -> offerSchema "schemaId" "FK" "vague"
                }
                offerWorker.repo -> offerDb "" "JDBC" "safe, sync, major"

                actorWorker = container Actor {
                    description "Сервис участников процесса"
                    !include ../../fragments/worker-dummy.pdsl
                    tags doubt
                }

                roleWorker = container "Role" {
                    !include ../../fragments/worker-dummy.pdsl
                    tags doubt
                }

                statusWorker = container Status {
                    description "Сервис статусов"
                    !include ../../fragments/worker-dummy.pdsl
                }
                statusDb = container "StatusDB" {
                    technology "PostreSQL 16"
                    tags db Postgres
                }
                statusWorker.repo -> statusDb "" "JDBC" "safe, sync, major"

                commentsWorker = container Comments {
                    !include ../../fragments/worker-dummy.pdsl
                    tags future Addon
                }

                messageWorker = container Notifier {
                    description "Сервис уведомлений"
                    !include ../../fragments/worker-dummy.pdsl
                    address = component addresser
                    templater = component templater
                    sender = component sender
                    task = component tasker
                    -> app "Оповещения" "SSE" "async, message, aux"
                }

                referenceWorker = container Reference {
                    description "Сервис справочников"
                    !include ../../fragments/worker-dummy.pdsl
                }
                refDb = container "ReferenceDB" {
                    technology "PostreSQL 16"
                    tags db Postgres

                    reference = component REFERENCE "Элементы справочников" Table "table"
                    referenceSchema = component REFERENCE_SCHEMA "Схемы справочников" Table "table"
                    registry = component REGISTRY "Справочники и списки" Table "table"
                    item = component ITEM "Элементы списков" Table "table"
                    reference -> referenceSchema "schemaId" "FK" "vague"
                    referenceSchema -> registry "registryId" "FK" "vague"
                    item -> registry "registryId" "FK" "vague"
                }
                referenceWorker.repo -> refDb "" "JDBC" "safe, sync, major"

                shipmentWorker = container "Shipment worker" {
                    !include ../../fragments/worker-dummy.pdsl
                    tags doubt
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
                //


            }

           
        }

            development = deploymentEnvironment "Back-End Development" {
                deploymentNode "ПК разработчика" "" {
                    deploymentNode "Docker Engine" {
                        deploymentNode "Воркеры" " " "Docker Compose" {
                            containerInstance yPortal.requestWorker
                            containerInstance yPortal.offerWorker
                            containerInstance yPortal.messageWorker
                            containerInstance yPortal.referenceWorker
                            containerInstance yPortal.shipmentWorker
                        }
                        deploymentNode "Cloud" "Docker-контейнер" "Ubuntu 22.10" {
                            containerInstance yPortal.consul
                            containerInstance yPortal.apiGateway
                        }
                    }
                }
                deploymentNode "Dev-стенд " "" {
                    deploymentNode "Docker Engine" {
                        deploymentNode "Camunda" "" "Docker Compose" {
                            softwareSystemInstance bpm


                        }
                        deploymentNode "Front" "" "Docker Compose" {
                            containerInstance yPortal.web
                        }
                        infrastructureNode "NGinx"
                    }
                }
            }

        // Production environment using Kubernetes
            production = deploymentEnvironment "Production" {
        //     // deploymentGroup "Kubernetes Cluster" {
        //     //     deploymentNode "Kubernetes Master" {
        //     //         // ...
        //     //     }
        //     //     deploymentNode "Kubernetes Node" {
        //     //         // ...
        //     //         // containerInstance trWorker {
        //     //         //     // ...
        //     //         // }
        //     //         // ... Other container instances
        //     //     }
            }
        
            yPortal.apiGateway -> bpm "Передача в БП" "gRPC" "sync, major, command, super"
            yPortal.apiGateway -> s3 "Хранение файлов" "HTTP" "safe, sync, aux"
            router -> yPortal.web "Управляет заявками" "HTTPS" "sync, major, request"
            dispatcher -> yPortal.app "Подтверждает перевозку" "HTTPS" "sync, request"
            dispatcher -> yPortal.web "Вносит предложения" "HTTPS" "sync, major, request"
            transport -> yPortal.app "Отчитывается о перевозке" "HTTPS" "sync, aux, message"

            yPortal.web -> yPortal.apiGateway Запрос "HTTPS REST/JSON NGINX" " sync, request, major"
            yPortal.app -> yPortal.apiGateway Запрос "HTTPS REST/JSON NGINX" " sync, request"
            yPortal.api -> yPortal.apiGateway "API call" "HTTPS REST/JSON NGINX" " sync, request"
            yPortal.apiGateway -> s3 "Файлы" "HTTP" "major, sync, safe"
            yPortal.web -> iam "Получение токена" "JWT" "check, sync, major, leap"
            yPortal.app -> iam "Получение токена" "JWT" "check, sync, major, leap"
            yPortal.apiGateway -> iam "Проверка токена" "JWT" "check, sync, major"
            bpm -> yms "Создает автовизит" "" "leap, vague, major"

        

    }

    // !script groovy {
    //     import  com.structurizr.view.ViewSet
    //     ViewSet views =        workspace.views
    //     views.systemLandscapeViews=null
    // }
    views {
        systemContext yPortal yp-context "Системный контекст Портала Перевозчика" {
            include *
            include queue->
            exclude "element.tag==db"
        }

        container yPortal yp-structure "Структура Портала Перевозчика" {
            include *
            include yms
            exclude relationship.tag==leap
            exclude relationship.tag==aux
            exclude "element.tag==external"
            exclude "element.tag==infra"
            exclude "element.tag==db"
            //exclude "element.tag==future"
            exclude "element.tag==doubt"
        }


        container yPortal infra-structure "Портала Перевозчика целиком" {
            include element.parent==yPortal
            include element==bpm
            include element==iam
            include element==s3
            exclude *->*
            exclude element==yPortal.api
            exclude "element.tag==external && element.tag!=abstract"

            //exclude "element.tag==db"
            //include element==yPortal.elastic
            //exclude "element.tag==future"
            exclude "element.tag==doubt"
            //exclude yPortal.apiGateway->*
            //exclude bpm->*
            //include *->yPortal.consul
        }


        deployment yPortal "Back-End Development" {
            include *
        }

        component yPortal.requestWorker request-structure "Компоненты микросервиса 'Заявка на перевозку'" {
            title "Заявка на перевозку"
              include *
            exclude bpm->*
        }

        component yPortal.requestWorker request-infra-structure "Компоненты инфраструктуры на примере микросервиса 'Заявка на перевозку'" {
            title "Spring Cloud"
            include *
            include "element.tag==infra && element.parent==yPortal"
            exclude element==bpm
        }

        component yPortal.refDb api-to-db "Схема ветвления запросов на примере сервиса Reference" {
            title "Потоки данных"
            include element==yPortal.web
            include element==yPortal.apiGateway
            include element==bpm
            //include element==yPortal.referenceWorker
            include element.parent==yPortal.referenceWorker
            include element.parent==yPortal.refDb
            exclude element.tag==infra
        }


        // dynamic yPortal yp-bidding "Процесс заявки на перевозку" {
        //     router -> yPortal.web "Создает заявку в web-форме" ""
        //     yPortal.web -> yPortal.apiGateway "Вызывает метод API"
        //     yPortal.apiGateway -> bpm "Маршрутизация на запуск процесса"
        //     bpm -> yPortal.requestWorker "Сохранить заявку"
        //     yPortal.requestWorker -> bpm "Вернуть ID"
        //     router -> bpm "Оформить заявку"
        //     bpm -> yPortal.requestWorker "Обновить заявку"
        //     yPortal.requestWorker -> bpm "ОК"
        //     bpm -> yPortal.messageWorker "Уведомление 'Новая заявка'"
        //     yPortal.messageWorker -> yPortal.app  "'Новая заявка'"
        //     yPortal.app -> dispatcher "Получает сообщение"
        //     dispatcher -> yPortal.web "Заполняет форму предложения"
        //     yPortal.web -> bpm "Запускает процесс 'Предложение'"
        //     bpm -> yPortal.offerWorker "Сохранить предложение"
        //     yPortal.offerWorker -> bpm "Вернуть ID"
        //     //bpm -> bpm "Отправить сообщение в процесс заявки" 
        //     router -> bpm "Выбрать победителя"
        //     dispatcher -> bpm "Подтвердить выполнение"
        //     bpm -> yms "Создать автовизит"
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
