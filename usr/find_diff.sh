#!/bin/bash
for i in $(find . -type d -name .git); do pushd $(dirname $i); git status -s; popd; done
