# Copyright 2023 Leidos
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:22.04

ARG CARLA_VERSION=0.10.0
# scenario_runner has no 0.10.0 tag; its UE5 (CARLA 0.10.x) support lives on ue5-master
ARG SCENARIO_RUNNER_VERSION=ue5-master

RUN apt update \
    && DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends --yes --quiet \
        libpng16-16 \
        libtiff5 \
        libjpeg8 \
        build-essential \
        git \
        python3.10 \
        python3.10-dev \
        python3-pip \
        libxerces-c-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
COPY . .
# Only the CARLA client Python API wheel is needed -- the agents package
# (GlobalRoutePlanner etc.) isn't, since none of our scenarios use it.
RUN python3 -m pip install --no-cache-dir "wheels/carla-$CARLA_VERSION-cp310-cp310-linux_x86_64.whl" \
    && ./install_carma_scenario_runner --prefix /app $SCENARIO_RUNNER_VERSION \
    && rm -rf /tmp/*

WORKDIR /app/scenario_runner
ENV PYTHONPATH "/app/carla"
# Set scenario runner root for carla recorder
ENV SCENARIO_RUNNER_ROOT  "/app/scenario_runner/"
ENTRYPOINT ["python3", "scenario_runner.py"]
