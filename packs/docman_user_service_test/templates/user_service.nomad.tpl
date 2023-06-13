job [[ template "job_name" . ]] {
    [[ template "region" . ]]

    namespace = [[ .docman_user_service_test.namespace | quote ]]

    datacenters = [[ .docman_user_service_test.datacenters | toStringList ]]

    constraint {
        attribute = [[ .docman_user_service_test.constraint.attribute | quote ]]
        value     = [[ .docman_user_service_test.constraint.value | quote ]]
    }
    
    group "docman_user_service_test" {
        network {
            mode = "bridge"
            port "https" {
                static = [[ .docman_user_service_test.docman_user_service_test_port_https ]]
            }
        }

        service {
            name = "[[ .docman_user_service_test.service_name_docman_user_service_test_https ]]"
            port = "https"
        }

        task "docman_user_service_test" {
            driver = "docker"
            
            template {
                data = <<EOF
                [[ .docman_user_service_test.secret]]
                EOF

                destination = "/local/env"
                env = true
            }

            template {
                data = <<EOF
                [[ .docman_user_service_test.certificate_rootca ]]
                EOF

                destination = "config/rootca.crt"
            }

            config {
                image = "[[ .docman_user_service_test.docman_user_service_test_image ]]:[[ .docman_user_service_test.docman_user_service_test_image_tag ]]"
                volumes = ["config/rootca.crt:/etc/ssl/certs/ca-certificates.crt"]
                [[- if .docman_user_service_test.auth_image ]]
                auth {
                     [[- range $var := .docman_user_service_test.docman_user_service_test_auth ]]
                     [[ $var.key ]] = [[ $var.value | quote ]]
                     [[- end ]]
                }
                [[- end ]]

                ports = ["https"]
            }

            resources {
                cpu    = [[ .docman_user_service_test.docman_user_service_test_resources.cpu ]]
                memory = [[ .docman_user_service_test.docman_user_service_test_resources.memory ]]
            }
        }
        
    task "docman_user_service_test_sidecar" {
            driver = "docker"
            config {
                image = "[[ .docman_user_service_test.sidecar_image ]]"
                ports = [
                "https",
                ]
                volumes = ["config/nginx.conf:/etc/nginx/nginx.conf", "secrets/certificate.crt:/secrets/certificate.crt", "secrets/certificate.key:/secrets/certificate.key"]
            }
            resources {
                cpu    = [[ .docman_user_service_test.docman_user_service_test_resources.cpu ]]
                memory = [[ .docman_user_service_test.docman_user_service_test_resources.memory ]]
            }
            template {
                data = <<EOF
                [[ .docman_user_service_test.nginx_conf_env ]]
                EOF

                destination = "config/nginx.conf"
            }

            template {
                data = <<EOF
[[ .docman_user_service_test.certificate_cert ]]
                EOF

                destination = "secrets/certificate.crt"
            }
            template {
                data = <<EOF
[[ .docman_user_service_test.certificate_key ]]
                EOF

                destination = "secrets/certificate.key"
            }
        }
    }
}
