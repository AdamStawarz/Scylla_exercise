# Scylla_Exercise_1

## Description

* Create a 3 nodes cluster, with one datacenter 
each of the nodes in a different rack , dc:north, racks north1, north2, north3
* Create a keyspace with 3 tables, one of the tables using STCS, another LCS, another TWCS.
* Insert 10,000 records in each of the tables, using loop and cqlsh.
* In the TWCS table, when creating the table and inserting data use time-window 30 minutes and the data to expire with 1 hour TTL
* Add a DC with 3 more nodes , each of the nodes in a different rack, dc: south, racks south1, south2, south3
* Install Scylla Manager
* Run repair using Scylla manager
* Decommission the old DC, keeping only the new created DC
* Add a node, decommission a node
* Then kill one of the nodes, destroy one of the containers (kill the seed node)
* Replace procedure to replace this node we've killed


## Getting Started

### Dependencies

* Linux, docker, docker-compose

### Create Clusters

* To create first cluster(north):

```
$ docker-compose -f docker-compose-dc1.yml up -d
    Creating network "sample_web" with driver "bridge"
    Creating sample_scylla-node3_1 ... done
    Creating sample_scylla-node2_1 ... done
    Creating sample_scylla-node1_1 ... done

$ docker exec -it sample_scylla-node1_1 nodetool status
Datacenter: north
=================
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address        Load       Tokens       Owns    Host ID                               Rack
UN  192.168.160.2  91.33 KB   256          ?       4a27a531-f250-458a-9bff-b1f05d24a834  north2
UN  192.168.160.3  90.91 KB   256          ?       e434ef65-256e-4631-8590-554ee72f6f3c  north3
UN  192.168.160.4  91.26 KB   256          ?       149e12c3-dcfa-4ab7-b4b1-4b1d9b4a4113  north1

```

* Insert data to DB (there is many option to do that) eg: 
    * Use bash to propagate data:
    ```
    $ docker exec -it sample_scylla-node1_1 bash

    $ ./run_inserts.sh 
            Bash version 4.2.46(2)-release...
            Creating CSV temp_data.csv
            Creating Keyspaces...
            Populating data...
            Reading options from the command line: {'header': 'TRUE', 'delimiter': ','}
            Using 7 child processes

            Starting copy of test_keyspace.tab_stcs with columns [id, first_name, last_name, location].
            Processed: 10000 rows; Rate:    6105 rows/s; Avg. rate:   10038 rows/s
            10000 rows imported from 1 files in 0.996 seconds (0 skipped).
            Reading options from the command line: {'header': 'TRUE', 'delimiter': ','}
            Using 7 child processes

            Starting copy of test_keyspace.tab_lcs with columns [id, first_name, last_name, location].
            Processed: 10000 rows; Rate:    6208 rows/s; Avg. rate:   10364 rows/s
            10000 rows imported from 1 files in 0.965 seconds (0 skipped).
            Reading options from the command line: {'header': 'TRUE', 'delimiter': ','}
            Using 7 child processes

            Starting copy of test_keyspace.tab_twcs with columns [id, first_name, last_name, location].
            Processed: 10000 rows; Rate:    6182 rows/s; Avg. rate:    9822 rows/s
            10000 rows imported from 1 files in 1.018 seconds (0 skipped).

    $ cqlsh -e "select count(*) from test_keyspace.tab_TWCS"

    count
    -------
    10000
    ```

    * Use Cassandra-stress tool:
    ```
    NOTE: 
    We can use yaml profiles to create schema:
    - cassandra_STCS_profile.yaml
    - cassandra_TWCS_profile.yaml    
    - cassandra_LCS_profile.yaml
    
    COMMANDS: 
    (use proper IP's)

    $ cassandra-stress user profile=./cassandra_TWCS_profile.yaml no-warmup ops\(insert=1\) n=10000 -rate threads=1 -node 192.168.176.2,192.168.176.3,192.168.176.4
    ```

* Add second cluster(south):
```
$ docker-compose -f docker-compose-dc2.yml up -d

Datacenter: north
=================
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address        Load       Tokens       Owns    Host ID                               Rack
UN  192.168.176.2  108.46 KB  256          ?       e4c95388-8b4f-41c9-8b72-fed301e13dba  north3
UN  192.168.176.3  108.7 KB   256          ?       e64abf0d-afb8-45be-b3b2-f693051e1452  north2
UN  192.168.176.4  108.43 KB  256          ?       bd25b189-d93f-40fa-b724-012c572fb4be  north1
Datacenter: south
=================
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address        Load       Tokens       Owns    Host ID                               Rack
UN  192.168.176.5  108.62 KB  256          ?       a9a770f7-a535-445a-b1b6-eb629f5a89ce  south1
UN  192.168.176.6  108.8 KB   256          ?       d18b8cbd-bd7e-403b-9ad9-a837481eb483  south2
UN  192.168.176.7  108.38 KB  256          ?       12aa3833-9e09-4b83-b2a6-c7e2d8c43ab2  south3

```

NOTE:
````
##### Remember to fix keyspaces on new DC #####

ALTER KEYSPACE test_keyspace WITH replication = { 'class' : 'NetworkTopologyStrategy', 'north' : 3, 'south' : 3};
ALTER KEYSPACE system_auth WITH replication = { 'class' : 'NetworkTopologyStrategy', 'north' : 3, 'south' : 3};
ALTER KEYSPACE system_distributed WITH replication = { 'class' : 'NetworkTopologyStrategy', 'north' : 3, 'south' : 3};
ALTER KEYSPACE system_traces WITH replication = { 'class' : 'NetworkTopologyStrategy', 'north' : 3, 'south' : 3};

##### Run nodetool rebuild on each node in the new datacenter, specify the existing datacenter name in the rebuild command.

For example:
nodetool rebuild -- <existing_data_center_name>

##### Run a full cluster repair, using nodetool repair -pr on each node, or using Scylla Manager ad-hoc repair

##### Update scylla.yaml file in the existing data-center(s) and the new data-center with the newly promoted seed nodes.

##### Restert each node:
For example:
sudo systemctl restart scylla-server
````

### Install Manager (docker)

* https://hub.docker.com/r/scylladb/scylla-manager

### Install Agents (docker)
* install agent on each node and populate token ()
```
$ yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
$ curl -o /etc/yum.repos.d/scylla-manager.repo -L http://downloads.scylladb.com/rpm/centos/scylladb-manager-2.2.repo
$ yum install scylla-manager-agent
```

* Add auth token to the yaml:
    * generate token: 
    ```
    $ scyllamgr_auth_token_gen
    ```
    * share the same token on each node:
    ```
    vi /etc/scylla-manager-agent/scylla-manager-agent.yaml
    ```
    * run service
    ```
    scylla-manager-agent -c /etc/scylla-manager-agent/scylla-manager-agent.yaml &
    ```
### Add cluster to manager:

```
docker exec -it scylla-manager sctool cluster add -c <cluster_name> --host=<host_ip> --auth-token=token
1a0feeba-5b38-4cc4-949e-6bd704667552
```
### Manager tasks

* Fire repair:
```
sctool repair -c prod-cluster
repair/3201ff14-6e8f-72b2-875c-d3c73f524410
```
* https://docs.scylladb.com/operating-scylla/manager/1.4/repair-a-cluster/

### Decommissioning DC
* https://docs.scylladb.com/operating-scylla/procedures/cluster-management/decommissioning_data_center/

### Other tasks
* Remove node
https://docs.scylladb.com/operating-scylla/procedures/cluster-management/remove_node/
* Add a Decommissioned Node Back to a Scylla Cluster
https://docs.scylladb.com/operating-scylla/procedures/cluster-management/revoke_decommission/
* Replace seed node
https://docs.scylladb.com/operating-scylla/procedures/cluster-management/replace_seed_node/



## Help

Documentation:
* https://docs.scylladb.com/operating-scylla/procedures/tips/best_practices_scylla_on_docker/
* https://docs.scylladb.com/operating-scylla/procedures/cluster-management/add_dc_to_existing_dc/
* https://thelastpickle.com/blog/2016/12/08/TWCS-part1.html
* https://medium.com/ksquare-inc/how-to-use-apache-c-e0ec2b3dee03
* https://www.instaclustr.com/deep-diving-cassandra-stress-part-3-using-yaml-profiles/


## Authors

Contributors names and contact info
* adam.stawarz@scylladb.com

## Version History

* 0.1
    * Initial Release
