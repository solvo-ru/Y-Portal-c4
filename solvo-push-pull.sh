
#Basic styles
/opt/structurizr-cli/structurizr.sh push -url http://structurizr.solvo.ru/api -id 1 -key 57befbca-538d-4d36-b2be-d34fbe92dd97 -secret 3336aed7-60ba-47e6-baa4-7a3839b4e01b -workspace dsl/themes/basic/styles.dsl -archive false

#Conductor
/opt/structurizr-cli/structurizr.sh push  -url http://structurizr.solvo.ru/api -id 2 -key 36237412-edb2-4621-8b0d-a1f4d96f2ae0 -secret 85acec99-4119-42b5-a472-def53f09ca21 -workspace dsl/systems/conductor/workspace.dsl -archive false

#Portal
/opt/structurizr-cli/structurizr.sh push -url http://structurizr.solvo.ru/api -id 3 -key 05080e34-7c4d-4a87-8f04-4d2031cb6ecc -secret ffd4af59-e203-479a-afaf-30bbaa6b91e7 -workspace dsl/systems/y-portal/workspace.dsl -archive false

#Cloud
/opt/structurizr-cli/structurizr.sh push -url http://structurizr.solvo.ru/api -id 4 -key c0bed49a-105d-46d0-845d-d7560250f217 -secret 85cfc67d-a719-4bbe-9473-49dd4ac9be85 -workspace dsl/systems/cloud/workspace.dsl -archive false

#Landscape
/opt/structurizr-cli/structurizr.sh push -url http://structurizr.solvo.ru/api -id 5 -key 8cc77281-fe21-4c24-be42-f7c2e9e0d6be -secret e0c1b5b5-e2ff-4a9c-8797-c6064c25fff6 -workspace dsl/solvo-landscape.dsl -archive false
