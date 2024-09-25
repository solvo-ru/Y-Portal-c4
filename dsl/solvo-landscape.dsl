workspace "Экосистема продуктов Solvo" {

    !identifiers hierarchical
    !impliedRelationships true

    configuration {
        visibility public
        scope landscape
        users {
            moarse write
            idonchenko@solvo.ru write
            guest read
        }
    }


    model {

        properties {
            structurizr.groupSeparator "/"
        }


        Group "Внешние бизнес-системы" {
            mdm = softwareSystem "MDM" "Система управления справочными данными" {
                tags External
                perspectives {
                    "Integration" "Синхронизация по расписанию"
                }
            }

            erp = softwareSystem "ERP" "Система планирования ресурсов предприятия" {
                tags External
                perspectives {
                    "Integration" "Двусторонний обмен"
                }
            }
            tms = softwareSystem "TMS" "Система управления транспортными операциями" {
                tags External
                perspectives {
                    "Integration" "Передача данных в реальном времени"
                }
            }
        }
        Group "Внешние системы безопасности" {
            idm = softwareSystem "IDM" "Система идентификации пользователей" {
                tags External
                perspectives {
                    Integration "SSO"
                }
            }
            ams = softwareSystem "AMS" "Система управления доступом пользователей" {
                tags External
                perspectives {
                    "Integration" "Авторизация в реальном времени "
                }
            }
        }

        yms = softwareSystem Yard "Система управления транспортными дворами" {
            tags Product future Solvo
            perspectives {
                "Integration" "Передача данных в реальном времени"
            }
        }
        wms = softwareSystem WMS {
            tags Product future Solvo
        }
        tos = softwareSystem TOS {
            tags Product future Solvo
        }
        yPortal = softwareSystem "Портал перевозчика" {
            tags Product Solvo
        }

        cloud = softwareSystem "Инфраструктура" {
            description "Набор компонент, обеспечивающих микросервисное окружение"
            tags Cloud Tool
        }

        bpm = softwareSystem "Оркестратор" {
            tags Orchestrator Pillar

        }

        iam = softwareSystem Keycloak {
            description "Управление аутентификацией и авторизацией"
            tags Keycloak Pillar
            perspectives {
                "Security" "OAuth 2.0 authentication"
                "Performance" "Масштабируемость для больших баз пользователей"
                "Scalability" "Горизонтальное масштабирование для высокой пропускной способности"
                "Availability" "Высокая доступность кластеризацией"
            }
        }

        s3 = softwareSystem Minio {
            description "Объектное S3-хранилище"
            tags Minio Pillar
        }

        queue = softwareSystem "Брокер сообщений" "Асинхронное взаимодействие" {
            tags Rabbit queue bus Tool
            perspectives {
                "Security" "SSL шифрование"
                "Performance" "Высокая пропускная способность"
                "Scalability" "Линейная масштабируемость"
                "Availability" "Отказоустойчивость  репликацией"
            }
        }
        yms -> queue "" "" "leap, vague, major"
        wms -> queue "" "" "leap, vague, major"
        tos -> queue "" "" "leap, vague, major"

        yportal -> bpm "Запуск бизнес-процессов" "HTTPS/gRPC" "command, sync, major"
        yportal -> iam "Аутентификация и авторизация" "HTTPS JWT" "check, sync, major"
        yportal -> s3 "Файлы" "HTTP" "major, sync, safe"
        queue -> mdm "Синхронизаця" "" "leap, vague"
        queue -> erp "" "" "leap, vague, major"
        iam -> idm "Внешняя аутентификация" "JWT/SSO/OAuth" "check, sync, aux"
        iam -> ams "Внешняя авторизация" "RBAC/ABAC" "check, sync, aux"
        queue -> tms "" "" "leap, vague, major"

        bpm -> queue "Интеграционное взаимодействие" "Connectors" "async, major, leap, message"
        bpm -> iam "Проверка доступа" "JWT" "check, major, sync"
        bpm -> yms "'Внутренняя' интеграция" "" "async, major, command"

    }


    views {
        theme http://structurizr.solvo.ru/share/3/a0a22ef6-206a-4a77-876d-a7f103b6f251/theme
        properties {
            "structurizr.timezone" "Europe/Moscow"
            "structurizr.locale" "ru-RU"
        }
    }
    !script scripts/landscape.groovy {

            }
    !script scripts/Tagger.groovy {
            }

}
