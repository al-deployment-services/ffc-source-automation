# ffc-source-automation

Bash script to automate Flat-File sources creation in the UI utilizing the LM API endpoint for createflatfilesource. The script uses credentials in a single config file: ~/.alertlogic/publicapi. Credentials must include two fields:
```
ACCOUNT: your alertlogic's account ID or CID
API_KEY: your alertlogic's user public API key
```

## Example:
```
ACCOUNT=123456
API_KEY=1a2b3c4d5e6f7g8h9i0j1a2b3c4d5e6f7g8h9i0j
```

To use the script, you must pass two variables, $HOSTNAME (log source name as appears in the UI) and $FFC_POLICY (existing flat-file policy name created in the UI).

```
$ ./ffc-source.sh <replace with hostname> <replace with an existing flat-file policy name>
```

Example usage and expected output:

```
$ ./ffc-source.sh i-0310ba90a66cfffc2 nginx_default_access_log
20171211-15:54:25 i-0310ba90a66cfffc2 check for existing source (HTTP 200)
20171211-15:54:26 i-0310ba90a66cfffc2 Get syslog source host id (HTTP 200)
20171211-15:54:27 i-0310ba90a66cfffc2 get flatfile policy (HTTP 200)
20171211-15:54:27 Create flatfile source i-0310ba90a66cfffc2_nginx_default_access_log (HTTP 201)
```

The script will locate the host_id required to setup the flat-file source in the UI automatically and POST the required JSON parameters to create the source.

You can run the script from your local terminal or integrate into other automation tools in place to run during first boot when the instance is launched (this will require a small modification by calling the AWS internal API on the instance first and return the instance ID value to use as HOSTNAME).

## Results in the UI:

![alt text](https://screenshots.firefoxusercontent.com/images/bcd81b49-e75e-407d-b2c8-e88b767f4010.png)


Credits
=======
[@twellspring](https://github.com/twellspring)
