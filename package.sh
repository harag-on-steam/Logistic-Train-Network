#!/usr/bin/sh
version_tag=$1
git archive --prefix LogisticTrainNetwork/ -o LogisticTrainNetwork_${version_tag}.zip ${version_tag}

