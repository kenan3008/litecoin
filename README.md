## Docker-ayes

Buit docker container can be retrieved by executing `docker pull dkenan/litecoin-test`

`Dockerfile` contains the code that will build a container with the `litecoin` binary, and verify its  gpg keys and sha checksums.
[Gosu](https://github.com/tianon/gosu) and [dumb-init](https://github.com/Yelp/dumb-init) are also installed.
`gosu` is used to ensure that the container is always running as a non-root user. `dumb-init` runs as PID 1, acting like a simple init system. It launches a single process and then proxies all received signals to a session rooted at that child process.
Since your actual process is no longer PID 1, when it receives signals from dumb-init, the default signal handlers will be applied, and your process will behave as you would expect. If your process dies, dumb-init will also die, taking care to clean up any other processes that might still remain. For more details, see the official readme of the `gosu` and `dumb-init`.

GPG keys are imported for binaries that have them define. For `dumb-init`, only sha is available. Message like this means the signature is valid. I wasn't sure if the docker build should fail or not on the checksum checks. If it's needed, add `sha256sum -c --strict -` instead of the existing code.

```
gpg: Signature made Wed Jun 10 04:57:17 2020 UTC
gpg:                using RSA key 59CAF0E96F23F53747945FD4FE3348877809386C
gpg: Good signature from "Adrian Gallagher <thrasher@addictionsoftware.com>" [unknown]
```

The check is performed by executing `gpg --verify` command. Verification process is inspised by [this](https://gist.github.com/losh11/48a7daddbcec0328491801e03a730177)

Container is scanned for vulnerabilities using Anchore. To get it up and running locally, use [this](https://anchore.com/blog/docker-image-security-in-5-minutes-or-less/) guide. At the time of the writing of this document, there was one *Medium* level vulnerability. All other vulnerabilities are either *Low* or *Negligible*. Full list of vulnerabilites is available in the document `anchore_vulnerabilities`.

## k8s FTW
Helm chart in folder `chart/litecoin` can be used to deploy a stateful set to the k8s cluster.
It creates a service account and a stateful set.
Default values are listed in the `values.yaml` file.

If Helm is not used in the deployment pipeline, manifest file can be generated from the chart, and then applied to the cluster using the following command:

```
helm template litecoin --release-name litecoin > statefulset.yaml
k apply -f statefulset.yaml
```

The output of these two commands is in the `statefulset.yaml` manifest file. This file will create a service account and a stateful set with litecoin container
in the Kubernetes cluster.

## Gitlab pipeline

Gitlab pipeline is available in the `.gitlab-ci.yaml` file. It contains two stages: `build` and `deploy`.
`build` stage builds the docker container and pushes it to the dockerhub registry.
`deploy` stage deploys the latest image to a staging cluster using the helm chart and `latest` image tag.

A better approach could be to build a new version of the helm chart along with a new image, push it to some registry and then deploy this helm chart referencing the correct image tag to staging.
Another solution could utilize GitOps approach and ArgoCD. Gitlab pipeline would make the necessary changes to a particular git repository monitored by ArgoCD. ArgoCD would then detect this change and make the necessary adjustments in the cluster.

## Script kiddies

Task: List of all users is available in the file `/etc/passwd`. Get username and home path of a user with ID `1000` .

Solution:

```
cat /etc/passwd | grep 1000 | awk -F':' '{print $1}'

cat /etc/passwd | grep 1000 | awk -F':' '{print $6}'
```

`cat /etc/passwd` prints out the whole content of the `etc/passwd`
`grep 1000` selects the line with the user id equal to 1000.
`awk -F':' '{print $1}'` defines `:` to be the delimiter, then selects the first field and outputs it.
`awk -F':' '{print $6}'` defines `:` to be the delimiter, then selects the sixth field and outputs it.

Content of the file used for testing is in the `etc_passwd_example` file.

## Script grown-ups

The same problem as in the previous section is solved in the `parse_etc_passwd.py` python script. The script accepts one argument`--uid` . It will then output the user name and home dir for the user.

The script utilizes the `argparse` to read command line arguments.

Usage:

```
$ python3 parse_etc_passwd.py -h
usage: parse_etc_passwd.py [-h] [--uid uid]

outputs user name and home dir for given uid

optional arguments:
  -h, --help  show this help message and exit
  --uid uid   uid of the user
```


Content of the file used for testing is in the `etc_passwd_example` file.

## Terraform

Be sure to define a profile `tf-devops-dev` in your credentials, to be able to run this code.

All the resources are located in the `terraform` folder.
There are two variables defined:
* `prefix` - environment where you are deploying, defaults to `prod`
* `aws_account` - ID of the AWS account you're using, no default value
