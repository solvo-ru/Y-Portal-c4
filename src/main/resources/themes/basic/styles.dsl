!const GREY  #8D98A7
!const BLUE3  #18162D
!const BLUE2  #0b5889
!const BLUE1  #3995D1
!const BLUE0   #62B1E7
!const RED3  #B12333 
//darker
!const RED2  #d9021c 
//basic
!const RED1  #FF707E 
//light
!const RED0  #FFC1CC 
//desaturated
!const CAMUNDA  #FC5D0D
!const SPRING  #6EB23F
!const GREEN  #6EB23F
!const FONT #003557
!const YELLOW  #FFBE47


workspace "Базовые стили" {
    model {
        system = softwareSystem system 
    }

    views {
        systemContext system "Cont" {
            include *
        }

        branding {
            font "Fira Code" https://fonts.googleapis.com/css2?family=Fira+Code
            logo icons/solvo-favicon.png
        }
        styles {

            relationship Relationship {
                thickness 4
                style solid
                routing Direct
                fontSize 20 
            }
            relationship HTTP {
                color ${BLUE3}
            } 
            relationship auth {
                routing Curved
                color ${GREY} 
                opacity 80
            }
            relationship leap { 
                thickness 1 
                style Dashed
            }
            relationship async { 
                style Dotted 
            }
            relationship gRPC { 
                color ${CAMUNDA}
                //style Dotted 
            }
            relationship GET {
                thickness 3
                color ${GREEN}
            }
            relationship job {
                thickness 2 
                routing Curved
                opacity 60
            } 

            relationship BPMN {
                thickness 2 
                routing Orthogonal
                color ${BLUE2} 
            }

            element Element {
                color ${FONT}
                strokeWidth 8 
                background ${BLUE0} 
            }            

            element Group  {
                fontSize 45 
               // color ${RED2}
            }

            element Boundary  {
                fontSize 60 
                strokeWidth 3 
                metadata false 
            }

            //Элементы первого уровня
            element Person {
                shape Person 
                metadata false 
                width 350 
                background white
                strokeWidth 5 
                stroke ${RED2} 
                fontSize 17 
            }

            element Analyst  {
                icon icons/anal.png 
            }

            element Administrator  {
                icon icons/devops.png 
            }

            element Security  {
                icon icons/seq.png 
            }

            element "Software System" {
                shape RoundedBox
                width 450 
                background white
                strokeWidth 12 
                fontSize 28 
                metadata false
            }

            element monolith {
                border dashed
            }

            element Product  {
                stroke ${RED2} 
                icon icons/solvo-icon.png 
            }

            element Keycloak  {
                stroke ${GREY}
                icon icons/keycloak.png  
            }
            element bus {
                width 2000 
                height 200 
            }

            element Orchestrator {
                shape Robot
                stroke ${CAMUNDA} 
                icon icons/orchestrator.png
            }

            element Queue {
                shape Pipe 
            }

            element Cloud {
                icon icons/cloud.png 
                stroke ${SPRING} 
                shape Ellipse
                width 600
            }

            element external {
                stroke ${FONT} 
            }


            element mobile {
                shape MobileDevicePortrait
            }

            element browser {
                shape WebBrowser 
            }
            element window {
                shape Window
            }

            element elk  {
                icon icons/elk.png
            }

            element Consul  {
                icon icons/consul.png 
            }



            //Элементы второго уровня
            element Container {
                shape RoundedBox 
                width 400 
                height 250 
                background ${BLUE2} 
                strokeWidth 8 
                //.strokeauto
                fontSize 24 
                color white
            }

            element OpenAPI {
                shape Folder
            }

            element solvo {
                background ${RED0}
                stroke ${RED1}
            }

            element db {
                shape Cylinder 
                width 300 
                height 300 
                background ${GREY} 
            }


            element Redis  {
                icon icons/redis.png 
                background #DC382C 
            }


            element Java  {
                icon icons/java.svg 
                background ${YELLOW} 
            }

            element Postgres {
                icon icons/postgresql.png 
                background #336791 
            } 


            element "Spring Cloud" {
                background ${SPRING} 
                icon icons/spring-cloud.svg 
            }

            element "Spring Boot" {
                icon icons/spring-boot.svg 
            }

            element Worker {
                shape Hexagon 
                width 350 
            }

            //Элементы третьего уровня
            element Component {
                shape Box 
                metadata false 
                width 400 
                height 150 
                background ${BLUE0} 
                strokeWidth 4 
                fontSize 16 
                color white 
            }


            element tiny { 
                width 320 
                height 100 
                strokeWidth 1 
            }

            element API {
                shape Circle 
                width 200 
                metadata false
            }

        }
    }
}