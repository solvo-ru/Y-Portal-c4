workspace "Экосистема продуктов Solvo" {

    !identifiers hierarchical
    !impliedRelationships true

    configuration {
        visibility public
        scope landscape
        users {
            moarse write
            guest read
        }
    }


    model {

        Group "Внешние бизнес-системы" {
            mdm = softwareSystem "MDM" "Система управления справочными данными"  {
                tags External 
                perspectives {
                    "Integration" "Синхронизация по расписанию"
                }
            }

            erp = softwareSystem "ERP" "Система планирования ресурсов предприятия"  {
                tags External  
                perspectives {
                    "Integration" "Двусторонний обмен"
                }
            }
            tms = softwareSystem "TMS" "Система управления транспортными операциями"  {
                tags External 
                perspectives {
                    "Integration" "Передача данных в реальном времени"
                }
            }
        }
        Group "Внешние системы безопасности" {
            idm = softwareSystem "IDM" "Система идентификации пользователей"  {
                tags External  
                perspectives {
                    Integration "SSO"
                }
            }
            ams = softwareSystem "AMS" "Система управления доступом пользователей"  {
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
            tags Product future  Solvo
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

        iam = softwareSystem "Keycloak" {
            description "Управление аутентификацией и авторизацией"
            tags Keycloak Pillar
            perspectives {
                "Security" "OAuth 2.0 authentication"
                "Performance" "Масштабируемость для больших баз пользователей"
                "Scalability" "Горизонтальное масштабирование для высокой пропускной способности"
                "Availability" "Высокая доступность кластеризацией"
            }
        }

        queue = softwareSystem "Брокер сообщений" "Асинхронное взаимодействие"  {
            tags Rabbit queue bus Tool
            perspectives {
                "Security" "SSL шифрование"
                "Performance" "Высокая пропускная способность"
                "Scalability" "Линейная масштабируемость"
                "Availability" "Отказоустойчивость  репликацией"
            }
        }
        yms -> queue "Текущие интеграции" "" "leap, vague, major"
        wms -> queue "Текущие интеграции"  "" "leap, vague, major"
        tos -> queue "Текущие интеграции"  "" "leap, vague, major"

        yportal -> bpm "Запуск процессов, выполнение задач" "HTTPS/gRPC" "command, sync, major"
        yportal -> iam "Доступ" "HTTPS JWT" "check, sync, major"
        queue -> mdm "Синхронизаця" "" "leap, vague"
        queue -> erp "" "" "leap, vague, major"
        iam -> idm "Аутентификация" "JWT/SSO/OAuth" "check, sync, aux"
        iam -> ams "Авторизация" "RBAC/ABAC" "check, sync, aux"        
        queue -> tms "" "" "leap, vague, major" 

        bpm -> queue "Интеграционное взаимодействие" "Connectors" "async, major, leap, message"
        bpm -> iam "Проверка доступа" "JWT" "check, major, sync"
        bpm -> yms "'Внутренняя' интеграция" "" "async, major, command" 
        
    }


 views {
        theme https://structurizr.moarse.ru/share/3/a0a22ef6-206a-4a77-876d-a7f103b6f251/theme
        properties {
            "structurizr.timezone" "Europe/Moscow"
            "structurizr.locale" "ru-RU"
        }
    }

            !script scripts/Tagger.groovy {
                type workspace
            }

}
