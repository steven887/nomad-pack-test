job [[ template "job_name" . ]] {
    [[ template "region" . ]]

    namespace = [[ .docman_user_service.namespace | quote ]]
    datacenters = [[ .docman_user_service.datacenters | toStringList ]]

    constraint {
        attribute = [[ .docman_user_service.constraint.attribute | quote ]]
        value     = [[ .docman_user_service.constraint.value | quote ]]
    }
    
    group "docman_user_service" {
        network {
            mode = "bridge"
            port "https" {
                static = [[ .docman_user_service.docman_user_service_port_https ]]
            }
            dns {
                servers = [
  "8.8.8.8",
  "8.8.4.4"
]
                searches = [
  "8.8.8.8",
  "8.8.4.4"
]
                options = [
  "8.8.8.8",
  "8.8.4.4"
]
            }

        }

        service {
            name = "[[ .docman_user_service.service_name_docman_user_service_https ]]"
            port = "https"
        }

        task "docman_user_service" {
            driver = "docker"
            
            template {
                data = <<EOF
                [[ .docman_user_service.secret]]
                EOF

                destination = "/local/env"
                env = true
            }

            template {
                data = <<EOF
                [[ .docman_user_service.certificate_rootca ]]
                EOF

                destination = "config/rootca.crt"
            }

            config {
                image = "[[ .docman_user_service.docman_user_service_image ]]:[[ .docman_user_service.docman_user_service_image_tag ]]"
                volumes = ["config/rootca.crt:/etc/ssl/certs/ca-certificates.crt"]
                [[- if .docman_user_service.auth_image ]]
                auth {
                     [[- range $var := .docman_user_service.docman_user_service_auth ]]
                     [[ $var.key ]] = [[ $var.value | quote ]]
                     [[- end ]]
                }
                [[- end ]]

                ports = ["https"]
            }

            resources {
                cpu    = [[ .docman_user_service.docman_user_service_resources.cpu ]]
                memory = [[ .docman_user_service.docman_user_service_resources.memory ]]
            }
        }
        
    task "docman_user_service_sidecar" {
            driver = "docker"
            config {
                image = "[[ .docman_user_service.sidecar_image ]]"
                ports = [
                "https",
                ]
                volumes = ["config/nginx.conf:/etc/nginx/nginx.conf", "secrets/certificate.crt:/secrets/certificate.crt", "secrets/certificate.key:/secrets/certificate.key"]
            }
            resources {
                cpu    = [[ .docman_user_service.docman_user_service_resources.cpu ]]
                memory = [[ .docman_user_service.docman_user_service_resources.memory ]]
            }
            template {
                data = <<EOF
                [[ .docman_user_service.nginx_conf_env ]]
                EOF

                destination = "config/nginx.conf"
            }

            template {
                data = <<EOF
[[ .docman_user_service.certificate_cert ]]
                EOF

                destination = "secrets/certificate.crt"
            }
            template {
                data = <<EOF
[[ .docman_user_service.certificate_key ]]
                EOF

                destination = "secrets/certificate.key"
            }
        }
    }
}
