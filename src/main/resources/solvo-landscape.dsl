workspace "Экосистема продуктов Solvo" {

    !identifiers hierarchical

    configuration {
        visibility public
        scope landscape
    }


    model {
        
        !include fragments/external.pdsl

        yms = softwareSystem Yard "Система управления транспортными дворами" {
            perspectives {
                "Integration" "Передача данных в реальном времени"
            }
        }
        wms = softwareSystem WMS
        tos = softwareSystem TOS
        yPortal = softwareSystem "Портал перевозчика"

        cloud = softwareSystem "Cloud Infrastructure"
        bpm = softwareSystem "Оркестратор"
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

    }

    views {
        theme https://structurizr.moarse.ru/workspace/3/theme
        properties {
            "structurizr.timezone" "Europe/Moscow"
            "structurizr.locale" "ru-RU"
        }
    }
}