ARG VERSION
FROM grafana/grafana:${VERSION}

USER root

RUN apk update && \
    apk add --no-cache curl jq 
    
USER grafana

# RUN for plugin in $(curl -s 'https://grafana.com/api/plugins?orderBy=name' | jq '.items[] | select(.internal == false) | .slug' | tr -d '"'); \
#     do grafana-cli --pluginsDir "${GF_PATHS_PLUGINS}" plugins install $plugin; done 

RUN for p in \
        "agenty-flowcharting-panel" \
        "aidanmountford-html-panel" \
        "bessler-pictureit-panel" \
        "bilibala-echarts-panel" \
        "blackmirror1-singlestat-math-panel" \
        "farski-blendstat-panel" \
        "flant-statusmap-panel" \
        "grafana-clock-panel" \
        "grafana-gitlab-datasource" \
        "grafana-oracle-datasource" \
        "grafana-polystat-panel" \
        "grafana-simple-json-datasource" \
        "grafana-singlestat-panel" \
        "larona-epict-panel" \
        "marcusolsson-csv-datasource" \
        "marcusolsson-dynamictext-panel" \
        "marcusolsson-json-datasource" \
        "michaeldmoore-multistat-panel" \
        "natel-discrete-panel" \
        "natel-plotly-panel" \
        "pierosavi-imageit-panel" \
        "ryantxu-ajax-panel" \
        "simpod-json-datasource" \
        "snuids-radar-panel" \
        "yesoreyeram-boomtheme-panel" \
    ; do \
        echo "Install Plugin $p"; \
        grafana-cli --pluginsDir "${GF_PATHS_PLUGINS}" plugins install "$p"; \
    done 
