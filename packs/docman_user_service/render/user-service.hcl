job "docman_user_service" {
    
    namespace = "docman-services-nonprod"
    
    datacenters = ["tbs-1"]

    constraint {
        attribute = "${meta.node_docman}"
        value = "true"
    }
    
    group "user-service" {
        network {
            mode = "bridge"

            port "user-service-http" {
                static = 40011
                to = 4001
            }
        }

        service {
            name = "docman-user-service-http"
            port = "40011"
        }

        task "user_service" {
            driver = "docker"

            template {
                data = <<EOF
                    ENV= "SIT"
                    APP_PORT= "4001"
                    MONGODB_URI= "mongodb://10.38.18.159:27017/"
                    HOST_DOCUMENT_SERVICE= "http://10.52.76.117:18080"
                    DB_USER_SERVICE= "docman_user_services_nonprod"
                    SECRET_KEY= "secret"
                    SET_TIMEOUT= "15"
                    IDENTITY_MANAGEMENT_TYPE= "ldap"
                    LDAP_BIND_DN= "CN=docman,OU=Services Accounts,DC=telkomsel,DC=co,DC=id"
                    LDAP_HOST= "10.250.200.176:389"

                EOF

                destination = "/local/env"
                env = true
            }

            config {
                image = "docker.cicd-jfrog.telkomsel.co.id/kholqifk/user:v1"
                ports = ["https"]
            }

            resources {
                cpu    = 800
                memory = 1024
            }
        }
    }
}

