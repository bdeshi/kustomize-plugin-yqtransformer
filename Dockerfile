ARG YQVERSION=4.48.1
FROM mikefarah/yq:${YQVERSION}

COPY --link --chmod=755 YqTransformer.sh /usr/local/bin/YqTransformer.sh
USER root
RUN apk add --no-cache bash
USER 1000
ENTRYPOINT ["/usr/local/bin/YqTransformer.sh"]
