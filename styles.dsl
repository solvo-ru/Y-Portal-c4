!const GREY  "#8D98A7"
!const BLUE3  "#063e63"
!const BLUE2  "#0b5889"
!const BLUE1  "#4d88b7"
!const BLUE0  "#0b5889"
!const RED3  "#a5000d" 
//darker
!const RED2  "#d9021c" 
//basic
!const RED1  "#ff4d5c" 
//light
!const RED0  "#b21222" 
//desaturated
!const CAMUNDA  "#FC5D0D"
!const SPRING  "#6EB23F"
!const GREEN  "#6EB23F"
!const FONT "#003557"

workspace "Базовые стили" {
    views {
        styles {

            relationship "Relationship" {
                thickness 3 
                style solid
                routing direct
                fontSize 20 
            }
            relationship "HTTP" {
                color ${BLUE3}
            } 
            // relationship LEAP_INTERACTION_TAG 
            //         .thickness 2 
            //         .style LineStyle.Dashed ;
            // relationship Tags.ASYNCHRONOUS 
            //         .style LineStyle.Dashed ;
            relationship "GET" {
                thickness 1
                color ${GREEN}
                routing curved
            }
            // relationship SERVICE_REGISTRATION_TAG 
            //         .thickness 2 
            //         .style LineStyle.Dotted 
            //         .color BLUE2 ;

            element "Element" {
                color ${FONT}
                strokeWidth 8 
                background ${BLUE0} 
            }

            element "solvo" {
                stroke ${RED2}
            }

            element "Group"  {
                fontSize 45 
                color ${RED2}
            }

            element "Boundary"  {
                fontSize 60 
                strokeWidth 3 
                metadata false 
            }

            //Элементы первого уровня
            element "Person"{
                shape Person 
                metadata false 
                width 350 
                background white
                strokeWidth 5 
                stroke ${RED2} 
                fontSize 17 
                color ${BLUE3}
            }

            element "Analyst"  {
                icon "icons/anal.png" 
            }

            element "Administrator"  {
                icon "icons/devops.png" 
            }

            element "Security"  {
                icon "icons/seq.png" 
            }

            element "Software System" {
                shape RoundedBox
                width 450 
                background white
                strokeWidth 12 
                stroke ${BLUE3} 
                fontSize 28 
                color ${BLUE3} 
            }

            element "mobile" {
                shape MobileDevicePortrait
            }

            element "browser" {
                shape WebBrowser 
            }

            element "elk"  {
                icon "icons/elk.png"
            }

            element "Consul"  {
                icon "icons/consul.png" 
            }

            element "Keycloak"  {
                icon "icons/keycloak.png" 
            }

            //Элементы второго уровня
            element "Container" {
                shape RoundedBox 
                width 400 
                height 250 
                background ${BLUE2} 
                strokeWidth 8 
                //.strokeauto
                fontSize 24 
                color white
            }

            element "db" {
                shape Cylinder 
                width 300 
                height 300 
                background ${GREY} 
            }

            element "Orchestrator" {
                shape RoundedBox 
                width 2000 
                height 170 
            }

            element "Redis"  {
                icon "icons/redis.png" 
                background "#DC382C" 
            }

            element "postgres" {
                icon "icons/postgresql.png" 
                background "#336791" 
            } 

            element "Camunda"  {         
                background ${CAMUNDA} 
            }

            element "Spring Cloud" {
                background ${SPRING} 
            }

            element "Worker" {
                shape Hexagon 
                width 350 
            }

            //Элементы третьего уровня
            element "Component" {
                shape Box 
                metadata false 
                width 400 
                height 150 
                background ${BLUE1} 
                strokeWidth 4 
                //.strokeauto
                fontSize 16 
                color "white" 
            }

            element "Queue" {
              shape Pipe 
            }

            element "tiny" { 
                width 320 
                height 100 
                strokeWidth 1 
            }

            element API_TAG {
                shape Circle 
                width 200 
            }

        }
    }
}