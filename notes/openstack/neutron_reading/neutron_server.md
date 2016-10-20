## neutron-server 启动流程：

星期四, 20. 十月 2016 04:53下午 

*/home/ayakashi/Code/neutron/neutron/cmd/eventlet/server/__init__.py*
```
def main():
  server.boot_server(_main_neutron_server)
  
def _main_neutron_server():
    if cfg.CONF.web_framework == 'legacy':
        wsgi_eventlet.eventlet_wsgi_server()
    else:
        wsgi_pecan.pecan_wsgi_server()  
```
*/home/ayakashi/Code/neutron/neutron/server/__init__.py*
```
def boot_server(server_func):
    # the configuration will be read into the cfg.CONF global data structure
    config.init(sys.argv[1:])	# 加载config
    config.setup_logging()	# log level设置
    config.set_config_defaults()	# 设置default config
    if not cfg.CONF.config_file:
        sys.exit(_("ERROR: Unable to find configuration file via the default"
                   " search paths (~/.neutron/, ~/, /etc/neutron/, /etc/) and"
                   " the '--config-file' option!"))
    try:
        server_func()
```
*/home/ayakashi/Code/neutron/neutron/server/wsgi_eventlet.py*
```
def eventlet_wsgi_server():
    neutron_api = service.serve_wsgi(service.NeutronApiService)
    start_api_and_rpc_workers(neutron_api)


def start_api_and_rpc_workers(neutron_api):
    try:
        worker_launcher = service.start_all_workers()

        pool = eventlet.GreenPool()
        api_thread = pool.spawn(neutron_api.wait)
        plugin_workers_thread = pool.spawn(worker_launcher.wait)

        # api and other workers should die together. When one dies,
        # kill the other.
        api_thread.link(lambda gt: plugin_workers_thread.kill())
        plugin_workers_thread.link(lambda gt: api_thread.kill())

        pool.waitall()
```
/home/ayakashi/Code/neutron/neutron/manager.py  加载各种plugin(core, type, mechanism, service)，至关重要的文件！！
```
        plugin_provider = cfg.CONF.core_plugin
        LOG.info(_LI("Loading core plugin: %s"), plugin_provider)
        self.plugin = self._get_plugin_instance(CORE_PLUGINS_NAMESPACE,
                                                plugin_provider)
        msg = validate_post_plugin_load()
        if msg:
            LOG.critical(msg)
            raise Exception(msg)

        # core plugin as a part of plugin collection simplifies
        # checking extensions
        # TODO(enikanorov): make core plugin the same as
        # the rest of service plugins
        self.service_plugins = {constants.CORE: self.plugin}
        self._load_service_plugins()
        # Used by pecan WSGI
        self.resource_plugin_mappings = {}
        self.resource_controller_mappings = {}
        self.path_prefix_resource_mappings = defaultdict(list)

```
*/home/ayakashi/Code/neutron/neutron/plugins/ml2/plugin.py*
```
    def __init__(self):
        # First load drivers, then initialize DB, then initialize drivers
        self.type_manager = managers.TypeManager()
        self.extension_manager = managers.ExtensionManager()
        self.mechanism_manager = managers.MechanismManager()
        super(Ml2Plugin, self).__init__()
        self.type_manager.initialize()
        self.extension_manager.initialize()
        self.mechanism_manager.initialize()
        registry.subscribe(self._port_provisioned, resources.PORT,
                           provisioning_blocks.PROVISIONING_COMPLETE)
        registry.subscribe(self._handle_segment_change, resources.SEGMENT,
                           events.PRECOMMIT_CREATE)
        registry.subscribe(self._handle_segment_change, resources.SEGMENT,
                           events.PRECOMMIT_DELETE)
        registry.subscribe(self._handle_segment_change, resources.SEGMENT,
                           events.AFTER_CREATE)
        registry.subscribe(self._handle_segment_change, resources.SEGMENT,
                           events.AFTER_DELETE)
        self._setup_dhcp()
        self._start_rpc_notifiers()
        self.add_agent_status_check_worker(self.agent_health_check)
        self.add_workers(self.mechanism_manager.get_workers())
        self._verify_service_plugins_requirements()
        LOG.info(_LI("Modular L2 Plugin initialization complete"))

```
*关于agent rpc*
```
ml2 plugin的rpc代碼，/home/ayakashi/Code/neutron/neutron/plugins/ml2/rpc.py
其他plugin的rpc代碼，如dhcp，/home/ayakashi/Code/neutron/neutron/api/rpc/agentnotifiers/dhcp_rpc_agent_api.py

*/home/ayakashi/Code/neutron/neutron/common/topics.py*

AGENT = 'q-agent-notifier'
PLUGIN = 'q-plugin'
SERVER_RESOURCE_VERSIONS = 'q-server-resource-versions'
L3PLUGIN = 'q-l3-plugin'
REPORTS = 'q-reports-plugin'
DHCP = 'q-dhcp-notifer'
METERING_PLUGIN = 'q-metering-plugin'

L3_AGENT = 'l3_agent'
DHCP_AGENT = 'dhcp_agent'
METERING_AGENT = 'metering_agent'\

可结合topic name 在 rabbitmq web ui中查看queue
```
*关于callback*
```
debug log中可以看到subscribe callback的操作	
```
