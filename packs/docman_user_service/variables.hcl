variable "job_name" {
    
  description = "The name to use as the job name which overrides using the pack cicd-user-service"
  type        = string
  // If "", the pack name will be used
  default = ""
  
}

variable "region" {
  description = "The region where jobs will be deployed"
  type        = string
  default     = ""
}

variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for task placement"
  type        = list(string)
  default     = ["dc1"]
}

variable "namespace" {
  description = "The region where jobs will be deployed"
  type        = string
  default     = "docman"
}

variable "constraint" {
    description = "enable constraints to selected nodes"
    type = object({
        attribute   = string
        value       = string
        })
        default = {
        attribute = "$${meta.node}"
        value     = "data"
        }
}

variable "service_name_docman_user_service_https" {
  description = "service name docman-user-service"
  type        = string
  default     = "docman-user-service"
}

variable "docman_user_service_port_http" {
  description = "docman-user-service port, this port use for docman-user-service connection"
  type = number
  default = 40011
}

variable "docman_user_service_port_https" {
  description = "docman-user-service port, this port use for docman-user-service connection"
  type = number
  default = 40012
}

variable "docman_user_service_port" {
  description = "docman-user-service port, this port use for docman-user-service connection"
  type = number
  default = 4001
}

variable "docman_user_service_image" {
  description = "Docker image for docman-user-service"
  type        = string 
  default     = "docker.cicd-jfrog.telkomsel.co.id/kliklabsautomation/user-service"
}

variable "docman_user_service_image_tag" {
  description = "Docker image tags for docman-user-service"
  type        = string
  default     = "alpha-69"
}

variable "auth_image" {
  description = "enable auth image" 
  type = bool
  default = false
}

variable "docman_user_service_auth" {
  description = "Docker image for docman-user-service"
  type = list(object({
    key   = string
    value = string
  }))
  default = [
    {key = "username", value = "0141ac0654a435498fb67862d1b4ba1309a08f190c8bbf780f5b0794b02c09b7"},
    {key = "password", value = "0141ac0654a435498fb67862d1b4ba1309a08f190c8bbf780f5b0794b02c09b7"}
  ]
}

variable "sidecar_image" {
  description = "Docker image for docman-user-service"
  type        = string 
  default     = "docker.cicd-jfrog.telkomsel.co.id/nginx"
}

variable "secret" {
  description = "environment secret docman-user-service"
  type = string
  default = <<EOF
    ENV= "SIT"
    APP_PORT= "4001"
    MONGODB_URI= "mongodb://10.38.18.159:27017/"
    {{ range service "docman-document-service" }}
    HOST_DOCUMENT_SERVICE= "https://{{ .Address }}:{{ .Port }}"
    {{ end }}
    DB_USER_SERVICE= "docman_user_services_nonprod"
    SECRET_KEY= "secret"
    SET_TIMEOUT= "300"
    IDENTITY_MANAGEMENT_TYPE= "ldap"
    LDAP_BASE_DN= "dc=telkomsel,dc=co,dc=id"
    LDAP_HOST= "10.250.193.116:389"
    LDAP_BIND_DN= "docman@telkomsel.co.id"
    LDAP_BIND_PASSWORD= "Ramadhan2023#"
  EOF
}

variable "nginx_conf_env" {
  type = string
  default = <<EOF
                    worker_processes  1;
    events {
      worker_connections  1024;
    }
    http {
      include       mime.types;
      default_type  application/json;
      sendfile        on;
      upstream user {
        server localhost:4001;
      }
      keepalive_timeout  65;
      server {
        listen       40012 ssl;
        server_name  localhost;
        ssl_certificate      /secrets/certificate.crt;
        ssl_certificate_key  /secrets/certificate.key;
        location / {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://user;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
        }
    }
  }

                EOF
}

variable "certificate_rootca" {
  description = ".crt"
  type = string
  default = <<EOF

-----BEGIN CERTIFICATE-----
MIIDBjCCAe4CCQDQmoqYV+KRMjANBgkqhkiG9w0BAQsFADBFMSQwIgYDVQQDDBtk
b2NtYW4ubm9ucHJvZC50ZWxrb21zZWwuaWQxCzAJBgNVBAYTAklEMRAwDgYDVQQH
DAdKYWthcnRhMB4XDTIzMDUxNjA5NDMyN1oXDTI0MDUxNTA5NDMyN1owRTEkMCIG
A1UEAwwbZG9jbWFuLm5vbnByb2QudGVsa29tc2VsLmlkMQswCQYDVQQGEwJJRDEQ
MA4GA1UEBwwHSmFrYXJ0YTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
ALUPM2m94plO5J5Hvf7nShe0n1GrPwKIO8usZj1tyQND/KOcfyDWrcaaqpxDqdb6
N4zgiIduykSHYmPteuq94NNCtcfAgsvM7OyWHkW5RPrpyrqEIIuaVoay4zM4S+oU
+zoskrvOviO+UdjycEq3vPjp/vc1FJggQ+ZDv9crdVGok6nBs6fjx00XvwRKSgjX
9eJCoaptaicH54DsOzqeYbopngT2LmP9Q/UyI9yuVZ57cT+uhO7JTLBA6hhmy3OO
+FPQVSWRpFvQ3xbq4YmgGt9XAVYuYLJA7l31EwK2Pia0Wy4k4oP3xt81j+zUf0hS
PSpi260C6skY1PQ80gJn988CAwEAATANBgkqhkiG9w0BAQsFAAOCAQEAoowpcqzq
HKIhcyDXtQ70jES1gmt9sPTYeSx9FIZiu12P+6wfYg/Uf8pzwEcUpve4mjBKwSxC
oEfJhnU2M1b5/VhiLJt9Lfd6unUuj7Qd9QXs2zyvylQhJV9/jMmKX3XMNT2tXYwZ
1bjU+hvpcekxW0YFqcSoCc1RONbNNWqjc6nFpWwrGyAvVdbaqjflayog/zkwMXIj
YYXqNTEeJSfC7SrKDblp3NSi+uTNAK7MWUbgZbw8d+8EY2aJU4j7JwoCQG0La5rx
1jhCZqrzJrzJcMTrHD2ZyupzkVX1Ii3EUzV/esybSjlcq564/7L/zlgtK9f8xGXd
HyRHtfoqWCZ6rA==
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIDWTCCAkGgAwIBAgIUXJc/WTVSjxRVTaRguXE7iypMVk4wDQYJKoZIhvcNAQEL
BQAwPDEbMBkGA1UEAwwSczMudGVsa29tc2VsLmNvLmlkMQswCQYDVQQGEwJJRDEQ
MA4GA1UEBwwHSmFrYXJ0YTAeFw0yMzAzMjAwNzQyMjNaFw0yNDAzMTAwNzQyMjNa
MDwxGzAZBgNVBAMMEnMzLnRlbGtvbXNlbC5jby5pZDELMAkGA1UEBhMCSUQxEDAO
BgNVBAcMB0pha2FydGEwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDP
yMvDBtSrXyNPRYl/qENf0eZtFSRhq4POHI+XZjWJlrwPE71q9EKPR27jFinWJxSi
A/VnrJPj7tGcBMeMJSgQhsrzztjKQUZF+IEnw5y4g1rcVZUsxv4i/GPwKzxf82gX
i5hbVxetEdy9qKl2tQ1dDj6ZJ9C/zq7aCcOYqnKkN9Hev/p9pwzLLXsveYDU30id
tiKH9NsdJJOGv5BWhI9z7agY7VrJq7AUykU011Xn7+FTz6X2lQj5mKvm0g9/xGUj
8wSwvZ+qaacXa74qddtZxhmeotWL4GBLpcHmcgEisbAow7k9uXqKbESH4/EQJn3N
6/iar+gTgsOD0k8O2KW/AgMBAAGjUzBRMB0GA1UdDgQWBBT9kIU9Wa5JlU0hkuTc
qWAFy9MRUjAfBgNVHSMEGDAWgBT9kIU9Wa5JlU0hkuTcqWAFy9MRUjAPBgNVHRMB
Af8EBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQAy2KeX9JRa2wf8bpBi7eMgKjUE
KSrIu7DQ55qkRjVpqzBPdxE2puhMuiikdIEv65QQbnr53cSt7dWfPIcxDni0Da0l
JAG0/TOOmzo+qQQV7RDVtZDn+BlaMD/0A+wkh/1vZCcB8fwNP99NbKXFED+AyPM2
HNQpEK7aXqBqP5JlFREpcGUCezkHs1atGmbrfPJesFmjEd6f/Zmx9MmnL668+mnl
FBdYB43c+gGj9Laa1AMOn8Wyr95mdUFPp6o2osYUl1kY75shkY2QEk2JalEHlvqp
meDKeyDIG8rckovwhT/hwDENZYDDt7PRyg4Bcv8QSYO0mn0bt8kzlR3rdLYk
-----END CERTIFICATE-----

  EOF
}

variable "certificate_cert" {
  description = ".cert"
  type = string
  default = <<EOF
-----BEGIN CERTIFICATE-----
MIIEFTCCAv2gAwIBAgIJAIFMsU/SIjOxMA0GCSqGSIb3DQEBCwUAMEUxJDAiBgNV
BAMMG2RvY21hbi5ub25wcm9kLnRlbGtvbXNlbC5pZDELMAkGA1UEBhMCSUQxEDAO
BgNVBAcMB0pha2FydGEwHhcNMjMwNTE2MDk0ODQ4WhcNMjQwNTE1MDk0ODQ4WjCB
iDELMAkGA1UEBhMCSUQxFDASBgNVBAgMC0RLSSBKYWthcnRhMRAwDgYDVQQHDAdK
YWthcnRhMRIwEAYDVQQKDAlUZWxrb21zZWwxFDASBgNVBAsMC0RldmVsb3BtZW50
MScwJQYDVQQDDB5kb2NtYW4ubm9ucHJvZC50ZWxrb21zZWwuY28uaWQwggEiMA0G
CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDy3l0epcJXUGVicNE7ckEoAXKtKngP
rGup61H33CgserYNDWk0ISGfkUNcxEHpVBRByw0XlnJ+HZKOTKezeEfjDdKh3JbU
TOHIVAvF8/hvQ/9vjSZv89mwYk9MnoV1D3bThyFvOsMRxmrOu76Oz8i666L//E++
rnw8PtnJ5xbuFVpckeyS7YV70ij+mfG2FOgpMFDtIvFKZCjEhoD8TG2LOnSTn4uT
GUU0mmoahgBEl5HdLWKbV6qTiMhw7R/ItKAzUDQ8xBHIJG+T1KF/19Gc08WfE/N5
SyASZlvwv1G0kXtZc6iuvH/VRXzqw6Qc4BXZyqVJW+ik5wbQIFJUCjVXAgMBAAGj
gcMwgcAwXwYDVR0jBFgwVqFJpEcwRTEkMCIGA1UEAwwbZG9jbWFuLm5vbnByb2Qu
dGVsa29tc2VsLmlkMQswCQYDVQQGEwJJRDEQMA4GA1UEBwwHSmFrYXJ0YYIJANCa
iphX4pEyMAkGA1UdEwQCMAAwCwYDVR0PBAQDAgTwMEUGA1UdEQQ+MDyHBAo0THOH
BAo0THSHBAo0THWHBAo0THaHBAo0THeHBAo0THiHBAo0THmHBAo0THqHBAo0THuH
BAo0THwwDQYJKoZIhvcNAQELBQADggEBACsbjSca9wWC+Qdd9lBYfi4FdRpsclwW
LDMkuOLCqlgSyeyyFuxaZ+fYX08g5xzbneLQK32OvmeP7Fo05phTpmDITCJlQ/Rf
mwky9PnBaSgku9EpAD6ewZiJuIoh4+zghtatJa2ai437JXwnzbYZAnuSpkMlcWb0
BJQTBB63vLHLPHDiJ1dqVuw90P3pO9lrMxix922G0QzJer6jNXvR5OJgsgP9M/F2
FLyByD97fuuNNf+gfWHqvLhF+7q4qulc8FHzcGDi2QiO29OpsQLpF5kpN0w1YXYm
tQ8w0stmOTitI3waAMbZqvnEizJUfuq999Zl3hTjGrIFrezV8m1aZ1c=
-----END CERTIFICATE-----

  EOF
}

variable "certificate_key" {
  description = ".key"
  type = string
  default = <<EOF
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA8t5dHqXCV1BlYnDRO3JBKAFyrSp4D6xrqetR99woLHq2DQ1p
NCEhn5FDXMRB6VQUQcsNF5Zyfh2Sjkyns3hH4w3SodyW1EzhyFQLxfP4b0P/b40m
b/PZsGJPTJ6FdQ9204chbzrDEcZqzru+js/Iuuui//xPvq58PD7ZyecW7hVaXJHs
ku2Fe9Io/pnxthToKTBQ7SLxSmQoxIaA/Extizp0k5+LkxlFNJpqGoYARJeR3S1i
m1eqk4jIcO0fyLSgM1A0PMQRyCRvk9Shf9fRnNPFnxPzeUsgEmZb8L9RtJF7WXOo
rrx/1UV86sOkHOAV2cqlSVvopOcG0CBSVAo1VwIDAQABAoIBAQDXvP8rAkOoHBpz
X5P9InkOeHrNqDQOeDMLNaYSbtag7EBbR9Z0IBomDHuyJAQIqE92QlDW6yW5MbvF
/AHcQrRY1SaN8c1puQG3WjE7HoVJETYOeWvzdsGhFTMr9ITIf3wmWpswmxo85+xo
yA11/s1ofXjFu/N6hrSFL6920nhj84jadUsxlwX5BB7vqI33jRYTu2bBWJ4U7MVX
QsdFjcgmWtFIbMQuSIFAEft5CEp4kQrC+15k8kW8QjZsUTotvolfA18IeQ32dSw3
4cdA/U8Pi9GNeDqAk4Fyl7RvACEJjrLPzb7+UdSIo9jlXLskUHnInh43deHX3tls
0uiQ544BAoGBAPnkN/WMtxXnYb7XNBKDICjYg4vCpE/H2d15AcV68oeQDIDxTi27
DBJ6ZBMR22GHTsbgnVsnF+vbN5lnVdHBK7vkzudydE9CRH9/0Z/nrBNTqigUYP2f
6jYN5rdjXoPCH7adYOeaVoBRdP++JdKvrpRjClKiEy0kaH0HnaokBkshAoGBAPjO
MngII0PaDMB3pOx2EJWowebq0qRDxIqHmrDYL8x+PqDXw4nXAsB/YNIu9dFt1X7g
QGCG2x7NG7wK7exFRXT5j7JoDihDg0OAVnSVXyPcwysZBtz5S4QlhuTdoycMg3HJ
02/MK/CNhbDh8PHSdXID7SV+bEIAnUd9PiOddSl3AoGBAOJID4gx6ORTxsY6N3P/
+xIhpVTcZ0+7KASN+9WoVI//F+N3HxT4CKF+5LoD9IUnMmWSpcsR5m5z7q/hy+uJ
oaGeOuGIWdwfpMlTpC3Jap+BplZuxblEoqBaDC7KM57aHT+O2V4/+s5tdKXUuIlE
/rBt0r4q93RsQJXfXJzhzDUhAoGADTcelSORg/QcA0kXmHu468oX6oUEhTcYRGdp
fwUsnMcD2pU7TKIAAmuBoAhghCw6T8/ne3kOQHeSho1qD8eqJclvqYE/Z0IWwcoa
TXz1nbkHIM3mgGw5Z556qMNg/Bz9Clk3AtQsbU2HEVse6ilMla7BtOEfLO5NbFOp
rkiZxYcCgYBdtXLNGqJNX1Y34alJHUX/n66emU8Gk2D81KHZwc2OHu98OvBSvNoV
RgGPCewPG+rk6mlxPYk/iz0tSoHobTa0pGmO9StHIwnhqNjCwZMl7DMV72e0y9AY
EWLNkXFd2S6SBkZcrbqLhZu2ldJ4y0yZNnhUiS7c4vKHFPk8EiDacw==
-----END RSA PRIVATE KEY-----
  EOF
}

variable "docman_user_service_resources" {
  description = "The resource to assign to the docman-user-service"
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 800,
    memory = 1024
  }
}
