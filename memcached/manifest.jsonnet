local kpm = import "kpm.libjsonnet";

function(
  params={}
)

kpm.package({
  package: {
    name: "quentinm/memcached",
    expander: "jinja2",
    author: "Quentin Machu",
    version: "0.1.0",
    description: "memcached",
    license: "Apache 2.0",
  },

  variables: {
    namespace: "default",

    deployment: {
      node_label: "openstack-control-plane",
      replicas: 1,
      image: "quay.io/stackanetes/stackanetes-memcached:barcelona",
    },

    network: {
      port: 11211,
    },
  },

  resources: [
    // Daemons.
    {
      file: "deployment.yaml",
      template: (importstr "templates/deployment.yaml"),
      name: "memcached",
      type: "deployment",
    },

    // Services.
    {
      file: "service.yaml",
      template: (importstr "templates/service.yaml"),
      name: "memcached",
      type: "service",
    },
  ],

  deploy: [
    {
      name: "$self",
    },
  ]
}, params)
