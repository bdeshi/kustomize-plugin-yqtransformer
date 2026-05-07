#!/bin/bash

# this kustomize transformer plugin modifies resources with yq expressions.
# the plugin accepts the following manifest structure:
# ```yaml
# targets:
#  - <target filter>
# expression: <yq expression>
# ```
# where each `target filter` is a partial resource manifest. the `yq expression`
# is applied to any resources that match *all attributes* in any target filter.

set -euo pipefail

# collect inputs
resource_list="$(</dev/stdin)"
configuration="$(yq '.functionConfig' -<<< "$resource_list")"
# extract configuration values
expression=$(echo "$configuration" | yq '.expression // "."')
target_list=$(yq '.targets // []' -<<< "$configuration")
target_count=$(yq '. | length' -<<< "$target_list")
resource_count=$(yq '.items | length' -<<< "$resource_list")

# if there are no targets, output the manifest as-is
if [ "$target_count" -eq 0 ]; then
    echo "$resource_list"
    exit 0
fi

# loop over each resource document in the manifest
for resource_index in $(seq 0 $((resource_count - 1))); do
    resource=$(yq ".items[$resource_index]" -<<< "$resource_list")
    comparison="continue"

    # try to match the resource against each target filter
    for target_index in $(seq 0 $((target_count - 1))); do
        target=$(yq ".[$target_index]" -<<< "$target_list")
        # compare sorted key-value pairs and print any leftover keys in target
        comparison=$(comm -23 \
            <(yq -oprops 'sort_keys(..)' -<<< "$target") \
            <(yq -oprops 'sort_keys(..)' -<<< "$resource") \
        )
        # $comparison is empty means no leftover keys, so a target matched
        [ -z "$comparison" ] && break
    done

    if [ -z "$comparison" ]; then
        # apply yq expression on current resource
        update=$(yq eval "$expression" -<<< "$resource")
        # replace current resource in the manifest with updated version
        resource_list=$( \
            yq eval-all \
            "select(fi==0).items[$resource_index] = select(fi==1) | select(fi==0)" \
            <(echo "$resource_list") <(echo "$update") \
        )
    fi
done

echo "$resource_list"
