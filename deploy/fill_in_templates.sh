#!/bin/bash

mkdir -p claims
mkdir -p deployments

USAGE="$0 <pattern> <storage_size>"
PATTERN=${1:?Please provide a pattern for mlabconfig: $USAGE}
GIGABYTES=${2:?Please give an integer number of gigabytes: $USAGE}

./operator/plsync/mlabconfig.py \
    --format=scraper_kubernetes \
    --template_input=deploy.yml \
    --template_output=deployments/deploy-{{site_safe}}-{{node_safe}}-{{experiment_safe}}-{{rsync_module_safe}}.yml \
    --select="${PATTERN}"

# Must do this sub before the mlabconfig call due to the fix for
#  http://bugs.python.org/issue17078
# not (yet) having propagated globally.
sed -e "s/{{GIGABYTES}}/${GIGABYTES}/" claim.yml > claim_template.yml
./operator/plsync/mlabconfig.py \
    --format=scraper_kubernetes \
    --template_input=claim_template.yml \
    --template_output=claims/claim-{{site_safe}}-{{node_safe}}-{{experiment_safe}}-{{rsync_module_safe}}.yml \
    --select="${PATTERN}"
