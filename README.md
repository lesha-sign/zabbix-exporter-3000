# zabbix-exporter-3000
just another zabbix exporter for [Prometheus](https://prometheus.io/)

like the other exporters it use Zabbix API and represent response as [Prometheus](https://prometheus.io/) metrics.

![Docker hub stats](https://img.shields.io/docker/pulls/rzrbld/ze3000?style=flat-square) ![GitHub License](https://img.shields.io/github/license/rzrbld/zabbix-exporter-3000?style=flat-square)

### Limitations:

Main limitation - one instance = one query.

### Configuration

| Variable |	Description |	Default |
| --- | --------- | ------- |
| <sub>ZABBIX_API_ENDPOINT</sub> | full url to Zabbix API | http://zabbix/api_jsonrpc.php |
| <sub>ZABBIX_USER</sub> | Zabbix user | admin |
| <sub>ZABBIX_PASSWORD</sub> | Zabbix password | admin |
| <sub>ZABBIX_SKIP_SSL</sub> | Skip Zabbix endpoint SSL check | true |
| <sub>ZE3000_STRICT_METRIC_REG</sub> | May be useful when you have an error about metric duplicate on registration - set this to false. On this case, you highly likely have a problem with query, but this may help you investigate. Don't set this to 'false' on real environment | true |
| <sub>ZE3000_SINGLE_METRIC</sub> | If you, for some reason, won't use Default mechanics with mapping metric name and field from Zabbix response.  | true |
| <sub>ZE3000_SINGLE_METRIC_HELP</sub> | Hardcoded HELP field for Single metric mechanics | single description |
| <sub>ZE3000_HOST_PORT</sub> | which host and port exporter should listening. Supported notations - 0.0.0.0:9080 or :9080 | localhost:8080 |
| <sub>ZE3000_METRIC_NAMESPACE</sub> | Metric namespace (part of metric name in Prometheus) | zbx |
| <sub>ZE3000_METRIC_SUBSYSTEM</sub> | Metric subsystem (part of metric name in Prometheus) | subsystem |
| <sub>ZE3000_METRIC_NAME_PREFIX</sub> | Metric name prefix | prefix |
| <sub>ZE3000_METRIC_NAME_FIELD</sub> | `Mapping field.` Which field form Zabbix response use as part of a name. Please note - this field will be trimmed, set to lower case and rid off of all symbols except A-z and 0-9. `Only top level Zabbix response fields supported`  | key_ |
| <sub>ZE3000_METRIC_VALUE</sub> | `Mapping field.` Which field form Zabbix response use as value of metric. `Only top level Zabbix response fields supported`| lastvalue |
| <sub>ZE3000_METRIC_HELP</sub> | `Mapping field.` Which field form Zabbix response use as help field of metric. `Only top level Zabbix response fields supported` | description |
| <sub>ZE3000_ZABBIX_METRIC_LABELS</sub> | `Mapping field.` Which field form Zabbix response use as labels. `This field supported first level and second level fields ` | name,<br>itemid,<br>key_,<br>hosts>host,<br>hosts>name,<br>interfaces>ip,<br>interface>dns |
| <sub>ZE3000_METRIC_URI_PATH</sub> | uri path where prometheus can consume metrics | /metrics |
| <sub>ZE3000_ZABBIX_REFRESH_DELAY_SEC</sub> | How frequent Zabbix exporter will be query Zabbix. In seconds | 10 |
| <sub>ZE3000_ZABBIX_QUERY</sub>  | any Zabbix query, with field "auth" with value "%auth-token%" - yes, literally `"%auth-token%"` |{"jsonrpc": "2.0",<br>"method": "item.get",<br>     "params": {<br>     	"application":"My Valuable Application",<br>         "output":["itemid","key_","description","lastvalue"],<br>         "selectDependencies": "extend",<br>         "selectHosts": ["name","status","host"],<br>         "selectInterfaces": ["ip","dns"],<br>         "sortfield":"key_" },<br>     "auth": "%auth-token%",<br>     "id": 1 } |

### How-to use
#### requirements
 - zabbix
 - prometheus
 - docker or k8s

#### description

Make some query to zabbix server over [Insomnia](https://insomnia.rest/download/), [Postman](https://www.postman.com/), [curl](https://curl.haxx.se/), you name it. Let's say this query is:
``` json
{
    "jsonrpc": "2.0",
    "method": "item.get",
    "params": {
    	"application":"My Super Application",
        "output": ["itemid","key_","description","lastvalue"],
        "selectDependencies": "extend",
        "selectHosts": ["name","status","host"],
        "selectInterfaces": ["ip","dns"],
        "sortfield":"key_"
    },
    "auth": "1234ml34kl3f4mk4gkl680klfmkl3fml",
    "id": 1
}
```

and response of this query is:
``` json

"jsonrpc": "2.0",
    "result": [
        {
            "itemid": "452345",
            "key_": "concurrencyConnections",
            "description": "The number of current concurrency connections.",
            "hosts": [
                {
                    "hostid": "54637",
                    "name": "Mighty Frontend",
                    "status": "2",
                    "host": "mighty.fronend"
                }
            ],
            "interfaces": [],
            "lastvalue": "9"
        },
        {
            "itemid": "902934",
            "key_": "numbeOfConnections",
            "description": "The number of currently active connections.",
            "hosts": [
                {
                    "hostid": "42092",
                    "name": "Mega Application",
                    "status": "0",
                    "host": "mega.application"
                }
            ],
            "interfaces": [
                {
                    "interfaceid": "1900",
                    "ip": "10.4.4.3",
                    "dns": ""
                }
            ],
            "lastvalue": "10987"
        },
      ],
  "id": 1
}

```
#### configure and run
Since we know the query and know what is return - let's configure and start Zabbix Exporter 3000:
ZE3000_ZABBIX_METRIC_LABELS - supports second level fields over `>` operator.

#### docker run

``` bash
docker run -d \
      -p 8080:8080 \
      -e ZABBIX_API_ENDPOINT=https://zabbix.example.com/zabbix/api_jsonrpc.php \
      -e ZABBIX_USER=someuser \
      -e ZABBIX_PASSWORD=str0nGpA5sw0rd \
      -e ZABBIX_SKIP_SSL=true \
      -e ZE3000_STRICT_METRIC_REG=true \
      -e ZE3000_METRIC_NAME_FIELD="key_" \
      -e ZE3000_SINGLE_METRIC=false \
      -e ZE3000_METRIC_NAMESPACE="megacompany" \
      -e ZE3000_METRIC_SUBSYSTEM="frontend" \
      -e ZE3000_METRIC_NAME_PREFIX="nginx" \
      -e ZE3000_METRIC_NAME_FIELD="key_" \
      -e ZE3000_METRIC_VALUE="lastvalue" \
      -e ZE3000_METRIC_HELP="description" \
      -e ZE3000_METRIC_URI_PATH="/my-metrics"
      -e ZE3000_ZABBIX_REFRESH_DELAY_SEC=20 \
      -e ZE3000_ZABBIX_METRIC_LABELS="itemid,key_,hosts>host,hosts>name,interfaces>ip,interface>dns" \
      -e ZE3000_HOST_PORT=localhost:8080 \
      -e ZE3000_ZABBIX_QUERY='{     "jsonrpc": "2.0",     "method": "item.get",     "params": {     	"application":"My Super Application",         "output": ["itemid","key_","description","lastvalue"],         "selectDependencies": "extend",         "selectHosts": ["name","status","host"],         "selectInterfaces": ["ip","dns"],         "sortfield":"key_"     },     "auth": "%auth-token%",     "id": 1 }' \
      rzrbld/ze3000:latest

```
:boom: let's suppose everything running ok, and you don't have any error messages from ze3000 <br/><br/>
by default ze3000 brings up next endpoints:
- `/metrics` - main and exported metrics (you can change it over ZE3000_METRIC_URI_PATH environment variable. In example above this env variable set to `/my-metrics`)
- `/ready` - readiness probe for k8s monitoring
- `/live` - liveness probe for k8s monitoring

Let's se at `/my-metrics`
``` bash
$ curl http://localhost:8080/my-metrics
...
megacompany_frontend_nginx_concurrencyconnections{hosts_host="mighty.fronend",hosts_name="Mighty Frontend",interface_dns="NA",interfaces_ip="10.4.4.3",itemid="452345",key_="concurrencyConnections"} 9
...
megacompany_frontend_nginx_numbeofconnections{hosts_host="mega.application",hosts_name="Mega Application",interface_dns="NA",interfaces_ip="NA",itemid="902934",key_="numbeOfConnections"} 10987


```
#### kubernetes run

Look at example deployments at `k8s` folder in this repo.

### How to build standalone binary

#### requirements
 - go 1.13+
 - git client

``` bash
$ git clone https://github.com/rzrbld/zabbix-exporter-3000
$ cd zabbix-exporter-3000
$ go build main.go
```
after that you need to export environment variables - just like in docker stage above and run as average binary.
