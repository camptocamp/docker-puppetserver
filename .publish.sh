#!/bin/bash -e
if ([ "$TRAVIS_BRANCH" == "master" ] || [ ! -z "$TRAVIS_TAG" ]) && \
  [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
  echo "Deploying image to docker hub"
  # Setup login
  openssl aes-256-cbc -K $encrypted_90dca2a3425d_key -iv $encrypted_90dca2a3425d_iv -in .dockercfg.enc -out ~/.dockercfg -d
  docker push "camptocamp/puppetserver:${TRAVIS_TAG}"
else
  echo "Not deploying image"
fi
