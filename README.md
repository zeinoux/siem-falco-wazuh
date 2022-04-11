<div align="center">
<p>
<img src="https://raw.githubusercontent.com/falcosecurity/community/master/logo/primary-logo.png" width="150"> 
<strong>feat</strong>
<img src="https://raw.githubusercontent.com/wazuh/wazuh-kibana-app/master/public/assets/logo.png" width="180">
</p>

## Cloud Native Runtime Security.
</div>

#### Table of Contents

1. [Overview](#overview)
2. [Description - What the module does and why it is useful](#description)
3. [File Information - include configuration and scripts](#list-important-file-information)
4. [Installation & Setup - Configuration options and additional functionality](#installation-and-setup)


## Overview
Falco-Wazuh Integration service, support with k8s v1.21.*+

## Description
Basic simple integration around falco and wazuh into k8s cluster with daemonset deployment,  is adopted  from https://github.com/Stuxend/falco-wazuh projects.

## List important file information 
- Files to deploy daemonset and service account
```
 k8/
├── deployment_cri_k8s.yaml
├── rbac-falco-wazuh_k8s_admin.yaml
└── README.md

3 files
```
- Wazuh server rules, import it into wazuh manager
```
 wazuh-rules/
├── 0485-falco.xml (__*this is decoders file*__)
├── 0685-falco_rules.xml (__*this is rules file*__)
├── old
│   ├── 0485-falco.xml
│   └── 0685-falco_rules.xml
└── README.md

1 directory, 5 files
```
- Agent files, docker entrypoint script, and default wazuh rules
```
agent
├── entrypoint.sh
├── falcolog
├── falco_rules.yaml
├── falco.yaml
├── ossec.conf
└── rootchecks
    ├── cis_apache2224_rcl.txt
    ├── cis_debian_linux_rcl.txt
    ├── cis_mysql5-6_community_rcl.txt
    ├── cis_mysql5-6_enterprise_rcl.txt
    ├── cis_rhel5_linux_rcl.txt
    ├── cis_rhel6_linux_rcl.txt
    ├── cis_rhel7_linux_rcl.txt
    ├── cis_rhel_linux_rcl.txt
    ├── cis_sles11_linux_rcl.txt
    ├── cis_sles12_linux_rcl.txt
    ├── cis_win2012r2_domainL1_rcl.txt
    ├── cis_win2012r2_domainL2_rcl.txt
    ├── cis_win2012r2_memberL1_rcl.txt
    ├── cis_win2012r2_memberL2_rcl.txt
    ├── rootkit_files.txt
    ├── rootkit_trojans.txt
    ├── system_audit_rcl.txt
    ├── system_audit_ssh.txt
    ├── win_applications_rcl.txt
    ├── win_audit_rcl.txt
    └── win_malware_rcl.txt
    
1 directory, 28 files
```
## Installation and setup

1. Please make sure to create wazuh namespace first, and apply serviceAccount via **k8/rbac-falco-wazuh_k8s_admin.yaml**
2. Before applying deployment file please edit this section :
```
        - name: wazuh_token
          valueFrom:
            secretKeyRef:
              name: wazuh-admin-token-8zzhf
              key: token
        - name: wazuh_cert
          valueFrom:
            secretKeyRef:
              name: wazuh-admin-token-8zzhf
              key: ca.crt 
```
*NB: Please matching created secrets, for _ex: wazuh-admin-token-xxxxx_

3. After editing token section, we can apply the deployment project vi **k8/deployment_cri_k8s.yaml**

That's all hope will be help,<br/>
Thank You

Regards,<br/><strong>
@zeinoux


