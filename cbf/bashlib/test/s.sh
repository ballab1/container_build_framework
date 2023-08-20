#!/usr/bin/bash

source ../loadLibraries.sh

environ.getHostIp "$(lib.getHost $(hostname -f))"

exit
environ.getHostIp "$(lib.getHost 'drp-grafana.cec.lab.emc.com')"
environ.getHostIp "$(lib.getHost 'https://drp-grafana.cec.lab.emc.com/')"
environ.getHostIp "$(lib.getHost 'amaas-eos-mw1.cec.lab.emc.com')"
environ.getHostIp "$(lib.getHost 'https://amaas-eos-mw1.cec.lab.emc.com/')"
environ.getHostIp "$(lib.getHost 'eos2git.cec.lab.emc.com')"
environ.getHostIp "$(lib.getHost 'https://eos2git.cec.lab.emc.com/')"
environ.getHostIp "$(lib.getHost 'osj-drp-01-prd.cec.lab.emc.com')"
environ.getHostIp "$(lib.getHost 'https://osj-drp-01-prd.cec.lab.emc.com/')"
environ.getHostIp "$(lib.getHost 'afeoscyc-mw.cec.lab.emc.com')"
environ.getHostIp "$(lib.getHost 'https://afeoscyc-mw.cec.lab.emc.com/')"
