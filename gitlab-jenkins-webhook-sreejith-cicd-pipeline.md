# GitLab Webhook Setup for Jenkins Pipeline

This document explains how to configure a GitLab webhook to trigger the Jenkins pipeline `sreejith_cicd_pipeline` whenever changes are pushed or merged into the `main` branch.

---

## 1. Why We Use Webhook

A webhook is used to automatically notify Jenkins when a change happens in GitLab.

Without a webhook, Jenkins will not know immediately when code is updated. You must start the build manually or use polling.

With a webhook:

- Developer pushes code to GitLab
- GitLab sends an HTTP request to Jenkins
- Jenkins automatically starts the pipeline
- Build, Docker image creation, push to Nexus, and Kubernetes deployment can happen automatically

---

## 2. Webhook Flow Diagram

```mermaid
flowchart LR
    A[Developer] -->|Push / Merge to main| B[GitLab Project<br/>devops_project2_mavenwebapp]
    B -->|Webhook Push Event| C[Jenkins URL<br/>/job/sreejith_cicd_pipeline/build]
    C --> D[Jenkins Pipeline<br/>sreejith_cicd_pipeline]
    D --> E[Maven Build]
    E --> F[Docker Build]
    F --> G[Push Image to Nexus]
    G --> H[Deploy / Update Kubernetes]

    style A fill:#dbeafe,stroke:#1d4ed8,stroke-width:2px,color:#000
    style B fill:#fde68a,stroke:#d97706,stroke-width:2px,color:#000
    style C fill:#bbf7d0,stroke:#16a34a,stroke-width:2px,color:#000
    style D fill:#fecaca,stroke:#dc2626,stroke-width:2px,color:#000
    style E fill:#e9d5ff,stroke:#7e22ce,stroke-width:2px,color:#000
    style F fill:#cffafe,stroke:#0891b2,stroke-width:2px,color:#000
    style G fill:#fed7aa,stroke:#ea580c,stroke-width:2px,color:#000
    style H fill:#dcfce7,stroke:#15803d,stroke-width:2px,color:#000
```

---

## 3. Install Required Jenkins Plugins

Go to:

```text
Jenkins Dashboard
→ Manage Jenkins
→ Plugins
→ Available Plugins
```

Install the below plugins:

```text
GitLab API Plugin
GitLab Plugin
GitLab Credentials - Kubernetes Integration
GitLab Checks API
GitLab Branch Source Plugin
```

### Explanation

| Plugin | Why It Is Used |
|---|---|
| GitLab API Plugin | Allows Jenkins to communicate with GitLab APIs |
| GitLab Plugin | Adds GitLab webhook and trigger support in Jenkins jobs |
| GitLab Credentials - Kubernetes Integration | Helps manage GitLab credentials in Jenkins/Kubernetes workflows |
| GitLab Checks API | Allows Jenkins to send status/check results back to GitLab |
| GitLab Branch Source Plugin | Useful for GitLab branch and multibranch pipeline integration |

---

## 4. Jenkins Pipeline Job

Pipeline name:

```text
sreejith_cicd_pipeline
```

Jenkins build URL format:

```text
https://jenkins.openhelp.net/job/sreejith_cicd_pipeline/build
```

### Explanation

This URL triggers the Jenkins job directly.

---

## 5. Jenkins API Token

The Jenkins API token is generated from:

```text
Jenkins
→ User: sreejith
→ Security
→ API Tokens
→ Generate New Token
```

Example token format:

```text
11c5d844679e81bf5a20c3451bf6490278
```

> **Important:** Do not commit real Jenkins API tokens into GitHub or documentation. Use a placeholder in public documents.

---

## 6. GitLab Webhook Configuration

Go to GitLab:

```text
GitLab
→ Project: devops_project2_mavenwebapp
→ Settings
→ Webhooks
→ Add new webhook
```

Webhook name:

```text
sreejith_cicd_pipeline
```

Webhook URL format:

```text
https://sreejith:<JENKINS_API_TOKEN>@jenkins.openhelp.net/job/sreejith_cicd_pipeline/build
```

Example safe format:

```text
https://sreejith:xxxxxxxxxxxxxxxxxxxxxxxx@jenkins.openhelp.net/job/sreejith_cicd_pipeline/build
```

### Explanation

- `sreejith` is the Jenkins login user
- `<JENKINS_API_TOKEN>` is the Jenkins API token generated from the user profile
- GitLab calls this URL when the selected event happens
- Jenkins receives the request and starts the pipeline

---

## 7. Secret Token Setting

For this method, leave the GitLab Secret Token field empty.

```text
Secret Token: empty
```

### Explanation

Authentication is already handled in the webhook URL using:

```text
https://username:api-token@jenkins-url/job/job-name/build
```

So a separate GitLab secret token is not required for this method.

---

## 8. Trigger Settings

Enable only:

```text
☑ Push events
```

Branch selection:

```text
Wildcard pattern: main
```

Disable the below options:

```text
☐ Tag push events
☐ Merge request events
☐ Comments
☐ Confidential comments
☐ Work item events
```

---

## 9. Why Push Event on main?

When a developer merges a Merge Request into `main`, GitLab creates a push event on the `main` branch.

So this setup works like this:

| GitLab Action | Jenkins Triggered? | Reason |
|---|---:|---|
| Push to feature branch | No | Branch filter allows only `main` |
| Open merge request | No | Merge request event is disabled |
| Merge request merged to main | Yes | GitLab creates a push event on `main` |
| Direct push to main | Yes | Push event on `main` matches the filter |

---

## 10. Test Webhook from GitLab UI

Go to:

```text
GitLab
→ Project: devops_project2_mavenwebapp
→ Settings
→ Webhooks
→ Test
→ Push events
```

Expected output:

```text
Hook executed successfully
```

### Explanation

This means GitLab successfully contacted Jenkins using the webhook URL.

---

## 11. Verify Build in Jenkins

Go to:

```text
Jenkins
→ sreejith_cicd_pipeline
→ Build History
```

Expected result:

```text
A new build should start automatically
```

Example Jenkins build history:

```text
#15  Started by remote host / GitLab webhook
#14  Started by user sreejith
#13  Started by user sreejith
```

---

## 12. Optional Command Line Test

You can also test the Jenkins build URL from the command line.

```bash
curl -I -u 'sreejith:<JENKINS_API_TOKEN>' \
  'https://jenkins.openhelp.net/job/sreejith_cicd_pipeline/build'
```

Expected sample output:

```text
HTTP/1.1 201 Created
Location: https://jenkins.openhelp.net/queue/item/123/
```

### Explanation

| Output | Meaning |
|---|---|
| `201 Created` | Jenkins accepted the build request |
| `Location: /queue/item/...` | Build was added to Jenkins queue |
| `403 Forbidden` | User/token permission issue |
| `404 Not Found` | Jenkins job URL is wrong |
| `401 Unauthorized` | Username or API token is wrong |

---

## 13. Final Expected Flow

```text
Developer merges code into main
        ↓
GitLab creates push event on main
        ↓
GitLab webhook sends request to Jenkins
        ↓
Jenkins starts sreejith_cicd_pipeline
        ↓
Pipeline builds and deploys application
```

---

## 14. Important Security Note

Do not expose the real Jenkins API token in GitHub README files, public documents, screenshots, or shared notes.

Use this format in documentation:

```text
https://sreejith:<JENKINS_API_TOKEN>@jenkins.openhelp.net/job/sreejith_cicd_pipeline/build
```

Or:

```text
https://sreejith:xxxxxxxxxxxxxxxxxxxxxxxx@jenkins.openhelp.net/job/sreejith_cicd_pipeline/build
```

---

## 15. Summary

The webhook connects GitLab and Jenkins. Whenever code is merged or pushed to the `main` branch, GitLab sends a push event to Jenkins, and Jenkins automatically starts the `sreejith_cicd_pipeline` job.

