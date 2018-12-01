# remote_audit

A cookbook to run inspec scans against remote nodes and report back to Chef Automate

# Usage

Create a wrapper cookbook and add a dependency on `remote_audit` in `metadata.rb`

``` ruby
depends 'remote_audit'
```

In the wrapper cookbook recipe, use the `remote_audit_scan` resource to run the audit and report to ChefAutomate

``` ruby
# This example runs 2 profiles against the loopback
# to test remote access over SSH (without needing another target node)

remote_audit_scan 'ncc-1701 multiple profiles' do
  profiles [
    { source: 'chef', owner: 'admin', profile: 'sample' },
    { source: 'chef', owner: 'admin', profile: 'cis-centos7-level1'}
  ]
  node_name 'ncc-1701'
  target 'ssh://root:vagrant@127.0.0.1'
end
```

# actions

| Action          | Description                            |
|-----------------|----------------------------------------|
| `:run`          | execute the remote scan                |
| `:nothing`      | do nothing                             |

# properties

| Property        | Description                                    |
|-----------------|------------------------------------------------|
| `profiles`      | an array of profile descriptor hashes          |
| `node_name`     | a unique name that represents the target host. |
| `target`        | an inspec remote target string                 |
