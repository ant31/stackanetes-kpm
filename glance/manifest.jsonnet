local kpm = import "kpm.libjsonnet";

function(
  params={}
)

kpm.package({
  package: {
    name: "stackanetes/glance",
    expander: "jinja2",
    author: "Quentin Machu",
    version: "0.1.0",
    description: "glance",
    license: "Apache 2.0",
  },

  variables: {
    deployment: {
      node_label: "openstack-control-plane",
      replicas: 1,

      image: {
        base: "quay.io/stackanetes/stackanetes-%s:barcelona",

        init: $.variables.deployment.image.base % "kolla-toolbox",
        db_sync: $.variables.deployment.image.base % "glance-api",
        api: $.variables.deployment.image.base % "glance-api",
        registry: $.variables.deployment.image.base % "glance-registry",
        post: $.variables.deployment.image.base % "kolla-toolbox",
      },
    },

    network: {
      ip_address: "{{ .IP }}",

      port: {
        api: 9292,
        registry: 9191,
      },

      ingress: {
        enabled: true,
        host: "%s.openstack.cluster",
        port: 30080,

        named_host: $.variables.network.ingress.host % "image",
      },
    },

    database: {
      address: "mariadb",
      port: 3306,
      root_user: "root",
      root_password: "password",

      glance_user: "glance",
      glance_password: "password",
      glance_database_name: "glance",
    },

    keystone: {
      auth_uri: "http://keystone-api:5000",
      auth_url: "http://keystone-api:35357",
      admin_user: "admin",
      admin_password: "password",
      admin_project_name: "admin",
      admin_region_name: "RegionOne",
      auth: "{'auth_url':'%s', 'username':'%s','password':'%s','project_name':'%s','domain_name':'default'}" % [$.variables.keystone.auth_url, $.variables.keystone.admin_user, $.variables.keystone.admin_password, $.variables.keystone.admin_project_name],

      glance_user: "glance",
      glance_password: "password",
      glance_region_name: "RegionOne",
    },

    ceph: {
      enabled: true,
      monitors: [],

      glance_user: "glance",
      glance_pool: "images",
      glance_keyring: "",
    },

    misc: {
      debug: false,
      workers: 8,
    },
  },

  resources: [
    // Config maps.
    {
      file: "configmaps/init.sh.yaml",
      template: (importstr "templates/configmaps/init.sh.yaml"),
      name: "glance-initsh",
      type: "configmap",
    },

    {
      file: "configmaps/db-sync.sh.yaml",
      template: (importstr "templates/configmaps/db-sync.sh.yaml"),
      name: "glance-dbsyncsh",
      type: "configmap",
    },

    {
      file: "configmaps/post.sh.yaml",
      template: (importstr "templates/configmaps/post.sh.yaml"),
      name: "glance-postsh",
      type: "configmap",
    },

    {
      file: "api/configmaps/ceph.client.glance.keyring.yaml",
      template: (importstr "templates/api/configmaps/ceph.client.glance.keyring.yaml"),
      name: "glance-cephclientglancekeyring",
      type: "configmap",
    },

    {
      file: "api/configmaps/ceph.conf.yaml",
      template: (importstr "templates/api/configmaps/ceph.conf.yaml"),
      name: "glance-cephconf",
      type: "configmap",
    },

    {
      file: "api/configmaps/glance-api.conf.yaml",
      template: (importstr "templates/api/configmaps/glance-api.conf.yaml"),
      name: "glance-glanceapiconf",
      type: "configmap",
    },

    {
      file: "api/configmaps/start.sh.yaml",
      template: (importstr "templates/api/configmaps/start.sh.yaml"),
      name: "glance-startsh",
      type: "configmap",
    },

    {
      file: "registry/configmaps/glance-registry.conf.yaml",
      template: (importstr "templates/registry/configmaps/glance-registry.conf.yaml"),
      name: "glance-glanceregistryconf",
      type: "configmap",
    },

    // Init.
    {
      file: "init.yaml",
      template: (importstr "templates/init.yaml"),
      name: "glance-init",
      type: "job",
    },

    {
      file: "db-sync.yaml",
      template: (importstr "templates/db-sync.yaml"),
      name: "glance-db-sync",
      type: "job",
    },

    {
      file: "post.yaml",
      template: (importstr "templates/post.yaml"),
      name: "glance-post",
      type: "job",
    },

    // Daemons.
    {
      file: "api/deployment.yaml",
      template: (importstr "templates/api/deployment.yaml"),
      name: "glance-api",
      type: "deployment",
    },

    {
      file: "registry/deployment.yaml",
      template: (importstr "templates/registry/deployment.yaml"),
      name: "glance-registry",
      type: "deployment",
    },

    // Services.
    {
      file: "api/service.yaml",
      template: (importstr "templates/api/service.yaml"),
      name: "glance-api",
      type: "service",
    },

    {
      file: "registry/service.yaml",
      template: (importstr "templates/registry/service.yaml"),
      name: "glance-registry",
      type: "service",
    },

    // Ingresses.
    if $.variables.network.ingress.enabled == true then
      {
        file: "api/ingress.yaml",
        template: (importstr "templates/api/ingress.yaml"),
        name: "glance-api",
        type: "ingress",
      },
  ],

  deploy: [
    {
      name: "$self",
    },
  ]
}, params)
