# remote_audit

A cookbook to run inspec scans against remote nodes and report back to Chef Automate

## Usage

Create a wrapper cookbook and add a dependency on `remote_audit` in `metadata.rb`

```
depends 'remote_audit'
```

In the wrapper cookbook recipe, use the `remote_audit_scan` resource to run the audit and report to ChefAutomate

```
remote_audit_scan 'ncc-1701-sample' do    # A unique name for the scan resource to avoid resource cloning warnings
  profile_name 'sample'                   # The profile name as shown in the Automate UI
  profile_user 'admin'                    # The automate user that owns the profile
  node_name 'ncc-1701'                    # The node name that will represent the remote host in the Automate UI
  target 'ssh://root:vagrant@127.0.0.1'   # The Inspec remote target URL (which may contain creds if Inspec can obtain them)
end
```
