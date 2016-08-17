local kpm = import "kpm.libjsonnet";

function(
  params={}
)

kpm.package({
  package: {
    name: "quentinm/rados-gateway",
    expander: "jinja2",
    author: "Quentin Machu",
    version: "0.1.0",
    description: "rados-gateway",
    license: "Apache 2.0",
  },

  variables: {
    deployment: {
      node_label: "openstack-control-plane",
      replicas: 1,
      image: {
        ceph_daemon: "ceph/daemon:latest"
      },
    },

    network: {
      external_ips: [],
      port: 6000,
    },

    # Ceph / Swift configuration.
    ceph_admin_keyring: "",
    ceph_monitors: [],
    swift_user_uid: "glance",
    swift_user_display_name: "User for Glance",
    swift_user: "glance:swift",
  },

  resources: [
    // Config maps.
    {
      file: "configmaps/ceph.client.admin.keyring.yaml",
      template: (importstr "templates/configmaps/ceph.client.admin.keyring.yaml"),
      name: "rados-gateway-cephclientadminkeyring",
      type: "configmap",
    },

    {
      file: "configmaps/ceph.conf.yaml",
      template: (importstr "templates/configmaps/ceph.conf.yaml"),
      name: "rados-gateway-cephconf",
      type: "configmap",
    },

    {
      file: "configmaps/start.sh.yaml",
      template: (importstr "templates/configmaps/start.sh.yaml"),
      name: "rados-gateway-startsh",
      type: "configmap",
    },

    // Daemons.
    {
      file: "deployment.yaml",
      template: (importstr "templates/deployment.yaml"),
      name: "rados-gateway",
      type: "deployment",
    },

    // Services.
    {
      file: "service.yaml",
      template: (importstr "templates/service.yaml"),
      name: "rados-gateway",
      type: "service",
    },
  ],

  deploy: [
    {
      name: "$self",
    },
  ]
}, params)
