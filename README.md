# remote_audit

A cookbook to run inspec scans against remote nodes and report back to Chef Automate

# Usage

Create a wrapper cookbook and add a dependency on `remote_audit` in `metadata.rb`

``` ruby
depends 'remote_audit'
```

In the wrapper cookbook recipe, use the `remote_audit_scan` resource to run the audit and report to ChefAutomate

# actions

| Action          | Description                            |
|-----------------|----------------------------------------|
| `:run`          | execute the remote scan                |
| `:nothing`      | do nothing                             |

# properties

| Property        | Description                                    | Required|
|-----------------|------------------------------------------------|---------|
| `profiles`      | an array of profile descriptor hashes          | Yes     |
| `node_name`     | a unique name that represents the target host. | Yes     |
| `target`        | an inspec remote target string                 | No      |
| `inputs`        | a hash of Inspec Inputs                        | No      |

# Example - A remote scan with 2 profiles

``` ruby
remote_audit_scan 'ncc-1701 multiple profiles' do
  profiles [
    { source: 'chef', owner: 'admin', profile: 'sample' },
    { source: 'chef', owner: 'admin', profile: 'cis-centos7-level1'}
  ]
  node_name 'ncc-1701'
  target 'ssh://root:vagrant@127.0.0.1'
end
```

# Example - A local scan with inputs

``` ruby
remote_audit_scan 'a local database' do
  profiles [
    { source: 'chef', owner: 'admin', profile: 'cis-oracle-database' },
  ]
  node_name 'database1.mynode.local'
  inputs(
    oracle_home: "/u01/apps/oracle",
    oracle_sid:  "database1"
  )
end
```
