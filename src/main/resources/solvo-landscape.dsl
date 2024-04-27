workspace "Экосистема продуктов Solvo" {

    !identifiers hierarchical
    !impliedRelationships true

    configuration {
        visibility public
        scope landscape
    }


    model {

        Group "Внешние системы" {
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
                perspectives {
                    "Integration" "Авторизация в реальном времени "
                }
            }
        }

        yms = softwareSystem Yard "Система управления транспортными дворами" {
            tags Product
            perspectives {
                "Integration" "Передача данных в реальном времени"
            }
        }
        wms = softwareSystem WMS {
            tags Product
        }
        tos = softwareSystem TOS {
            tags Product
        }
        yPortal = softwareSystem "Портал перевозчика" {
            tags Product
        }

        cloud = softwareSystem "Инфраструктура" {
            description "Набор компонент, обеспечивающих микросервисное окружение"
            tags Cloud
        }

        bpm = softwareSystem "Оркестратор" {
            tags Orchestrator
        }

        iam = softwareSystem "Keycloak" {
            description "Управление аутентификацией и авторизацией"
            tags "Keycloak"
            perspectives {
                "Security" "OAuth 2.0 authentication"
                "Performance" "Масштабируемость для больших баз пользователей"
                "Scalability" "Горизонтальное масштабирование для высокой пропускной способности"
                "Availability" "Высокая доступность кластеризацией"
            }
        }

        queue = softwareSystem "Очередь сообщений" "Асинхронная связь между микросервисами" "Kafka, Queue" {
            perspectives {
                "Security" "SSL шифрование"
                "Performance" "Высокая пропускная способность"
                "Scalability" "Линейная масштабируемость"
                "Availability" "Отказоустойчивость  репликацией"
            }
        }

        //###
        yportal -> mdm "НСИ sync" "" "Relationship"
        yportal -> erp "доступность ресурсов" "" "Relationship"
        yportal -> idm "" "" "Relationship"
        yportal -> ams "" "" "Relationship"
        bpm -> queue "" "" "Relationship"
        bpm -> iam "Авторизация" "" "Relationship"
        yportal -> bpm "Запуск процессов, Выполнение userTask" "" ""
        yportal -> queue "Подписка" "" ""
        bpm -> yms "Создает автовизит" "" "Relationship"
        yportal -> tms "Отслеживание транспорта" "" ""

    }
    views {
        theme https://structurizr.moarse.ru/workspace/3/theme
        properties {
            "structurizr.timezone" "Europe/Moscow"
            "structurizr.locale" "ru-RU"
        }
    }
}
