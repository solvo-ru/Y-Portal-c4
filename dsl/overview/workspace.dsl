workspace {
    name "Портал перевозчика - Cloud MVP"
    description "Обзор архитектурного кандидата"

    configuration {
        visibility public
        users {
            moarse write
            guest read
        }
    }

    model {



            arch = softwareSystem "Компоненты архитектуры" "Обзор систем, сервисов и инструментов"  {
                !docs docs/arch
            }

            data = softwareSystem "Концепция хранения данных" "Описание //почти-NoSQL// подхода документального хранилища "  {
                !docs docs/data
            }
            mock = softwareSystem "Прототип" "Обзор BPMN-моделера, конструктора форм, запуск Mocker"  {
                !docs docs/mock
            }
        

    }
    views {
            terminology {
    //person <term>
    softwareSystem раздел
    container вопрос
    //component <term>
    //deploymentNode <term>
    //infrastructureNode <term>
    //relationship <term>
    }
    }




}
