# What is NeoLoad Controller?
-----------------------------
[NeoLoad](https://www.neotys.com/neoload/overview) is a load testing solution developed by [Neotys](https://www.neotys.com). NeoLoad realistically simulates user activity and monitors infrastructure behavior so you can eliminate bottlenecks in all your web and mobile applications.
NeoLoad controller uses one or many Load Generators to generate the load against the server under test.

This image allows you to run NeoLoad tests within two different scopes:
* **Managed by NeoLoad Web** - The NeoLoad Controller is connected to NeoLoad Web which initiates the test (only available since NeoLoad 6.7)
* **Stand-Alone usage** - The NeoLoad Controller runs a test from the project and license specified as environment parameters.  Results can be optionally pushed live to NeoLoad Web.

It is recommended to use external Load Generators such as [Docker Load Generators](https://hub.docker.com/r/neotys/neoload-loadgenerator).
This image must be used with NeoLoad shared licenses and [Neotys Team Server](https://www.neotys.com/documents/doc/nts/latest/en/html/).

Managed by NeoLoad Web
======================
The NeoLoad Controller is connected to NeoLoad Web which initiates the test.
    
    docker run -d --rm \
            -e MODE=Managed
            -e NEOLOADWEB_URL={nlweb-onpremise-apiurl:port} \
            -e NEOLOADWEB_TOKEN={nlweb-token} \
            -e NTS_URL={nts-url} \
            -e NTS_LOGIN={login:password} \
            neotys/neoload-controller

### Parameters
| Env | Comment | Example |
| ------------------------ | --------------------------------------------- | ---------------- |
| MODE | Use '**Managed**' to let NeoLoad Web manage this Controller.  | Managed |
| NEOLOADWEB_TOKEN | The NeoLoad Web API token. | 9be32780c6ec86d92jk0d1d25c |
| NEOLOADWEB_URL (Optional) |  The NeoLoad Web API URL. Optional, is only required for NeoLoad Web OnPremise deployment. If not present, the Controller will use NeoLoad Web SAAS. | https://neoload.mycompany.com:8080 |
| NEOLOADWEB_PROXY (Optional / Since 6.10) | The proxy URL to access NeoLoad Web | http://login:password@myproxy |
| NEOLOADWEB_WORKSPACE (Optional / Since 7.4) | The NeoLoad Web Workspace (name or ID) | myWorkspace 
| LEASE_SERVER (Optional) | Which server used to get licence. The default value is NTS | NTS or NLWEB |
| NTS_URL (Not for NLWeb lease) | The NTS URL to lease the license. | http://nts.mycompany.com/nts |
| NTS_LOGIN (Not for NLWeb lease) | Credential to access the NTS. | me:A5C4RjYqGTHq6Pk2uAJBwA== |
| ZONE (Optional) | The Zone ID of the Controller, default value is the default Zone ID. | myZoneId |
| CONTROLLER_XMX (Optional) | Max memory of the Controller. | -Xmx1024m |
| AGENT_XMX (Since 7.0 / Optional) | Max memory of the Controller agent. | -Xmx256m |

> Note: The passwords of NTS_LOGIN must be encrypted with [our password scrambler](https://www.neotys.com/documents/doc/neoload/latest/#6418.htm).

Stand-Alone Usage
=================
The NeoLoad Controller runs a test from the project and license specified as environment parameters.  Results can be optionally pushed live to NeoLoad Web.

### With the Load Generators listed in the Project
    docker run -d --rm \
            -e PROJECT_NAME={project-name} \
            -e SCENARIO={scenario} \
            -e NTS_URL={nts-url} \
            -e NTS_LOGIN={login:password} \
            -e COLLAB_URL={collab-url} \
            -e LICENSE_ID={license-id} \
            -e VU_MAX={vu-max} \
            -e DURATION_MAX={duration-max} \
            -e NEOLOADWEB_URL={nlweb-onpremise-apiurl:port} \
            -e NEOLOADWEB_TOKEN={nlweb-token} \
            -e PUBLISH_RESULT={publish-result} \
            neotys/neoload-controller

### With overridden Load Generators
Create a Load Generator override file by following [documentation of --override-lg parameter](https://www.neotys.com/documents/doc/neoload/latest/#643.htm#o38549).
Map your created file to the container by adding the following option to the previous example.
The new line must be added before the *neotys/neoload-controller* line.

        -v /path/to/your/local/lg/file:/tmp/lg.txt \

Then you must add the --override-lg parameter using the OTHER_ARGS environment variable like this:
Add the following option to the previous example before the *neotys/neoload-controller* line.

        -e OTHER_ARGS=--override-lg /tmp/lg.txt

### Parameters
| Env | Comment | Example |
| ------------------------ | --------------------------------------------- | ---------------- |
| PROJECT_NAME | The name of the project | myProject |
| SCENARIO | The name of the scenario to run | myScenario |
| COLLAB_URL | The URL of the VCS to get the project | http://nts.mycompany.com/nts/svnroot/repository |
| COLLAB_LOGIN (Optional) | The credential to checkout the project from the VCS | me:A5C4Rj2uAJBwA== |
| RESULT_NAME (Optional) |  The name of the result | Simple test |
| DESCRIPTION (Optional) | The description of the test result | My CI automated test |
| NTS_URL | The NTS URL to lease the license | http://nts.mycompany.com/nts |
| NTS_LOGIN | Credential to access the NTS | me:A5C4RjYqGTHq6Pk2uAJBwA== |
| LEASE_SERVER (Optional) | Which server used to get licence. The default value is NTS | NTS or NLWEB |
| LICENSE_ID (Optional for NLWeb lease) | The license ID to lease | MCwCFQEsC7JH7fJM8Lk0FP3gkQ== |
| VU_MAX | Number of VU to lease | 250 |
| DURATION_MAX |  License lease duration in hours | 2 |
| PUBLISH_RESULT | Where to publish result: NTS, WEB (for neoload web) or ALL  | ALL |
| NEOLOADWEB_URL (Optional) |  The NeoLoad Web API URL | https://neoload.mycompany.com:8080 |
| NEOLOADWEB_TOKEN (Optional) | The NeoLoad Web API token | 9be32780c6ec86d92jk0d1d25c | 
| NEOLOADWEB_PROXY (Optional / Since 6.10) | The proxy URL to access NeoLoad Web | http://login:password@myproxy |
| NEOLOADWEB_WORKSPACE (Optional / Since 7.4) | The NeoLoad Web Workspace (name or ID) | myWorkspace 
| OTHER_ARGS (Optional) | Other arguments | -variables env=preprod |
| CONTROLLER_XMX (Optional) | Max memory of the controller | -Xmx1024m |
| LOADGENERATOR_XMX (Optional) | Max memory of the Load Generator | -Xmx2048m |

These parameters refer to the command line argument of `NeoLoadCmd`. For more information, see [List of arguments](https://www.neotys.com/documents/doc/neoload/latest/#643.htm#o38549).
If the max memory limit is not set, it will be automatically set at the recommended ratio.

> Note: The passwords of NTS_LOGIN and COLLAB_LOGIN must be encrypted with [our password scrambler](https://www.neotys.com/documents/doc/neoload/latest/#6418.htm). The proxy password can be encrypted too with the prefixed encryption.

License
---------
NeoLoad is licensed under the following [License Agreement](https://www.neotys.com/documents/legal/eula/neoload/eula_en.html). You must agree to this license agreement to download and use the image.

Note: This license does not permit further distribution.

Supported Docker versions
--------------------------------
This image is officially supported on Docker version 1.11.0.
Support for older versions (down to 1.6) is provided on a best-effort basis.
Please see [the Docker installation documentation](https://docs.docker.com/installation/) for details on how to upgrade your Docker Deamon.

User Feedback
------------------
For general issues relating to NeoLoad you can get help from [Neotys Support](https://www.neotys.com/community/?from=%2Faccountarea%2Fcasecreate.php) or [Neotys Community](http://answers.neotys.com/).