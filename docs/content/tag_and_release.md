## Tag and Release instructions

When in the need of releasing a new version of the charts, proceed as follows:
1. Make sure all the required changes are committed in the git repo; that `git status` should be clean with no uncommitted changes or left-behind files.
2. Bump the chart version in `Chart.yaml` (example for [mgm 0.1.2](https://gitlab.cern.ch/eos/eos-charts/-/commit/0a150e320ad0a37db29853512657a5cd09880eda)) and commit the change.
    ```
    [root@edocker eos-charts]# vim mgm/Chart.yaml 
    [root@edocker eos-charts]# git add mgm/Chart.yaml
    [root@edocker eos-charts]# git commit -m "mgm: Bump chart version to 0.1.2"
    [devel 0a150e32] mgm: Bump chart version to 0.1.2
     1 file changed, 1 insertion(+), 1 deletion(-)
    ```
3. Tag the repository at this point in time. The tag name must be _precisely_ in format `<eos-component>@<chart-version>`. Examples: `qdb@0.1.1`, `mgm@0.1.2`, `server@0.1.4`.
This allows the configured CI pipeline ([.gitlab-ci.yml](https://gitlab.cern.ch/eos/eos-charts/-/blob/master/.gitlab-ci.yml)) to run on GitLab and push the new chart automatically on [Harbor](https://registry.cern.ch/).
    ```
    [root@edocker eos-charts]# git tag -a mgm@0.1.2 -m "mgm at 0.1.2"
    [root@edocker eos-charts]# git push origin mgm@0.1.2
    Counting objects: 1, done.
    Writing objects: 100% (1/1), 164 bytes | 0 bytes/s, done.
    Total 1 (delta 0), reused 0 (delta 0)
    To https://:@gitlab.cern.ch:8443/eos/eos-charts.git
     * [new tag]         mgm@0.1.2 -> mgm@0.1.2
    ```
4. The CI on GitLab will resolve the chart dependencies, lint it, and push it to the chart repository on [Harbor](https://registry.cern.ch/harbor/projects/512/helm-charts).
This is an example of a successful build for `mgm@0.1.2`: [CI 20646776](https://gitlab.cern.ch/eos/eos-charts/-/jobs/20646776)
    ```
    ++ helm dependency update mgm
    Hang tight while we grab the latest from your chart repositories...
    ...Successfully got an update from the "eos" chart repository
    Update Complete. ⎈Happy Helming!⎈
    Saving 1 charts
    Downloading utils from repo https://registry.cern.ch/chartrepo/eos
    Deleting outdated charts
    ++ helm cm-push mgm/ eos
    Pushing mgm-0.1.2.tgz to eos...
    Done.
    ```
