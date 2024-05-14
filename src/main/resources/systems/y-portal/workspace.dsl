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
        transport = person "Водитель" "" {
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
                    -> bpm "Запуск процессов, Выполнение userTask" "Gateway, Zeebe" "leap, command, major"
                }

                app = container "Carrier App" "Мобильное приложение перевозчиков" {
                    tags mobile Solvo Addon
                    perspectives {
                        "Security" "Биометрическая аутентификация"
                        "Scalability" "Поддержка большого количества одновременных пользователей"
                        "Availability" "Синхронизация с сервером при наличии подключения"
                    }
                    -> bpm "Запуск процессов, Выполнение userTask" "Gateway, Zeebe" "leap, message, major"
                }

                api = container "Public API" "Публичный API Портала" {
                    tags Addon-cont Addon
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
            Group Cloud {
                !include ../../fragments/cloud.pdsl      
                 
            }
            apiGateway -> yPortal.consul "Регистрация, конфигурация" "aux, collect, safe"
            bpm -> yPortal.consul "Регистрация, конфигурация" "aux, collect, safe"



            Group BackEnd {

                requestWorker = container "Request worker" {
                   // !docs docs/request
                    properties {
                        wiki.document.id 6V4RDZuJnJ
                    }
                    description "Сервис заявок на перевозку" 
                    !include ../../fragments/worker-dummy.pdsl  
                }
                trDb = container "Request Database" {
                    technology "PostreSQL 16"
                    tags db Postgres 
                }
                requestWorker.repo -> trDb "" "JDBC" "safe, sync, major"

                offerWorker = container "Offer worker" { 
                    description "Сервис предложений"
                    !include ../../fragments/worker-dummy.pdsl
                }
                offerDb = container "Offer Database" {
                    technology "PostreSQL 16"
                    tags db Postgres 
                }
                offerWorker.repo -> offerDb "" "JDBC" "safe, sync, major"

                actorWorker = container "Actor" {                    
                    description "Сервис участников процесса"
                    !include ../../fragments/worker-dummy.pdsl     
                    tags doubt            
                }

                roleWorker = container "Role" {
                    !include ../../fragments/worker-dummy.pdsl
                    tags doubt 
                }

                statusWorker = container Status {
                    !include ../../fragments/worker-dummy.pdsl
                }

                commentsWorker = container commentsWorker {
                    !include ../../fragments/worker-dummy.pdsl
                    tags future 
                }

                messageWorker = container "Notifier" {
                    !include ../../fragments/worker-dummy.pdsl
                    address = component Addresser
                    templater = component templater
                    sender = component sender
                    task = component tasker
                    -> app "Оповещения" "SSE" "async, message, major" 
                }

                referenceWorker = container "Reference" {
                    !include ../../fragments/worker-dummy.pdsl
                }
                refDb = container "Master Data DB" {
                    technology "PostreSQL 16"
                    tags db Postgres 
                }
                referenceWorker.repo -> refDb "" "JDBC" "safe, sync, major"

                shipmentWorker = container "Shipment worker" {
                    !include ../../fragments/worker-dummy.pdsl  
                    tags future
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

            !script ../../scripts/Tagger.groovy {
                type system
            }
        }

        development = deploymentEnvironment "Back-End Development" { 
            deploymentNode "ПК разработчика" "" { 
                deploymentNode "Docker Engine" {
                    deploymentNode "Воркеры" " " "Docker Compose"{
                        containerInstance yPortal.requestWorker                     
                        containerInstance yPortal.offerWorker 
                        containerInstance yPortal.messageWorker 
                        containerInstance yPortal.referenceWorker 
                        containerInstance yPortal.shipmentWorker
                    }
                    deploymentNode "Cloud" "Docker-контейнер" "Ubuntu 22.10"{
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
        yPortal.apiGateway -> bpm "Запуск процессов, выполнение задач" "gRPC" "sync, major, command" 
        // apiGateway -> tasklist "управление процессами" "HTTP REST/JSON" "HTTP"
        // apiGateway -> operate "техподдержка" "HTTP REST/JSON" "HTTP"
        // apiGateway -> optimize "администрирование" "HTTP REST/JSON" "HTTP"
        // apiGateway -> keycloak "проверяет токен" "JWT" "HTTP"
        router -> yPortal.web "Управляет заявками, отслеживает перевозки" "HTTPS" "sync, major, request"
        dispatcher -> yPortal.app "Подтверждает перевозку" "HTTPS" "sync, aux, request"
        dispatcher -> yPortal.web "Вносит предложения" "HTTPS" "sync, major, request"
        transport -> yPortal.app  "Отчитывается о перевозке" "HTTPS" "sync, aux, message"

        yPortal.web -> yPortal.apiGateway "Отправляет запрос" "HTTPS REST/JSON NGINX" "leap, sync, request, major"
        yPortal.app -> yPortal.apiGateway "Отправляет запрос" "HTTPS REST/JSON NGINX" "leap, sync, request, aux"
        //publicApi -> apiGateway "Отправляет запрос"
        
        yPortal.web ->  iam "Получение токена" "JWT" "check, sync, major, leap"
        yPortal.app ->  iam "Получение токена" "JWT" "check, sync, major, leap"
        yPortal.apiGateway -> iam "Проверка токена" "JWT" "check, sync, major"
        bpm -> yms "Создает автовизит" "" "leap, vague, major"
        yPortal.web -> tms "Отслеживание транспорта" "HTTPS" "leap, vague, aux"

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
            exclude "element.tag==infra"
            exclude "element.tag==db"
            exclude "element.tag==future"
            exclude "element.tag==doubt"
        }


        container yPortal infra-structure "Инфраструктура Портала Перевозчика" {
            include element.parent==yPortal
            include element==bpm
            exclude relationship.tag==leap 
            exclude element==yPortal.app
            exclude element==yPortal.api
            exclude element==yPortal.web
            exclude "element.tag==external && element.tag!=abstract"
           
            //exclude "element.tag==db"
             exclude "element.tag==future"
            exclude "element.tag==doubt"
        }


         deployment yPortal "Back-End Development" {
             include *
         }
        component yPortal.requestWorker request-structure "Компоненты микросервиса 'Заявка на перевозку'" {
            include *
            exclude bpm->*
        }


        dynamic yPortal yp-bidding "Процесс заявки на перевозку" {
            router -> yPortal.web "Создает заявку в web-форме" ""
            yPortal.web -> yPortal.apiGateway "Вызывает метод API"
            yPortal.apiGateway -> bpm "Маршрутизация на запуск процесса"
            bpm -> yPortal.requestWorker "Сохранить заявку"
            yPortal.requestWorker -> bpm "Вернуть ID"
            router -> bpm "Оформить заявку"
            bpm -> yPortal.requestWorker "Обновить заявку"
            yPortal.requestWorker -> bpm "ОК"
            bpm -> yPortal.messageWorker "Уведомление 'Новая заявка'"
            yPortal.messageWorker -> yPortal.app  "'Новая заявка'"
            yPortal.app -> dispatcher "Получает сообщение"
            dispatcher -> yPortal.web "Заполняет форму предложения"
            yPortal.web -> bpm "Запускает процесс 'Предложение'"
            bpm -> yPortal.offerWorker "Сохранить предложение"
            yPortal.offerWorker -> bpm "Вернуть ID"
            //bpm -> bpm "Отправить сообщение в процесс заявки" 
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