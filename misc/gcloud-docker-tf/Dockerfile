FROM hashicorp/terraform:light AS terraform
FROM docker@sha256:453c52a7a7200677f9effa3acc8498a2f71af77c2951ac5e1ac1391053573374

COPY --from=terraform /bin/terraform /bin/terraform

ENV CLOUD_SDK_VERSION="245.0.0"
ENV PATH=/opt/google-cloud-sdk/bin:$PATH

WORKDIR /opt

RUN wget https://github.com/DeviaVir/terraform-provider-customconfig/releases/download/v0.0.1/terraform-provider-customconfig_0.0.1_linux_amd64.tgz \
 && tar xzf terraform-provider-customconfig_0.0.1_linux_amd64.tgz \
 && mkdir -p $HOME/.terraform.d/plugins/ \
 && mv terraform-provider-customconfig_v0.0.1 $HOME/.terraform.d/plugins/

RUN apk --no-cache add curl python py-crcmod bash libc6-compat openssh-client git gnupg \
 && curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
 && tar xzf google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
 && rm google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
 && ln -s /lib /lib64

RUN /opt/google-cloud-sdk/bin/gcloud config set core/disable_usage_reporting true \
 && /opt/google-cloud-sdk/bin/gcloud config set component_manager/disable_update_check true \
 && /opt/google-cloud-sdk/bin/gcloud config set metrics/environment github_docker_image \
 && /opt/google-cloud-sdk/bin/gcloud auth configure-docker

