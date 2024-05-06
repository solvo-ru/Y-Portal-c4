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
        }
        Group "Внешние системы безопасности" {
            idm = softwareSystem "IDM" "Система идентификации пользователей" "external" {
                perspectives {
                    Integration "SSO"
                }
            }
            ams = softwareSystem "AMS" "Система управления доступом пользователей" "external" {
                perspectives {
                    "Integration" "Авторизация в реальном времени "
                }
            }
        }

        yms = softwareSystem Yard "Система управления транспортными дворами" {
            tags Product monolith
            perspectives {
                "Integration" "Передача данных в реальном времени"
            }
        }
        wms = softwareSystem WMS {
            tags Product monolith
        }
        tos = softwareSystem TOS {
            tags Product monolith
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

        queue = softwareSystem "Очередь сообщений" "Асинхронная связь между микросервисами" "Rabbit, Queue, bus" {
            perspectives {
                "Security" "SSL шифрование"
                "Performance" "Высокая пропускная способность"
                "Scalability" "Линейная масштабируемость"
                "Availability" "Отказоустойчивость  репликацией"
            }
        }
        yms -> queue "Текущие интеграции" "" "leap"
        wms -> queue "Текущие интеграции"  "" "leap"
        tos -> queue "Текущие интеграции"  "" "leap"

        yportal -> bpm "Запуск процессов, выполнение задач" "HTTPS/gRPC" ""
        yportal -> iam "Доступ" "HTTPS JWT" "auth"
        queue_mdm = queue -> mdm
        queue -> erp "" "" ""
        iam -> idm "Аутентификация" "JWT/SSO/OAuth"
        iam -> ams "Авторизация" "RBAC/ABAC" ""        
        queue -> tms "" "" ""

        bpm -> queue "Интеграционное взаимодействие" "Connectors"
        bpm -> iam "Проверка доступа" "JWT" "auth"
        bpm -> yms "'Внутренняя' интеграция" "" ""
        bpm -> bpm "Взаимодействие процессов" "Call Activity / Collaboration / Message / Signal" "BPMN"

}
 views {
        theme https://structurizr.moarse.ru/share/3/a0a22ef6-206a-4a77-876d-a7f103b6f251/theme
        properties {
            "structurizr.timezone" "Europe/Moscow"
            "structurizr.locale" "ru-RU"
        }
    }
}
