
---

````markdown
# DevOps Microservices Project on AWS EKS

This project demonstrates a real-world DevOps workflow using:
- AWS EKS (Elastic Kubernetes Service)
- Terraform (Infrastructure as Code)
- Node.js Microservices
- ECR (Elastic Container Registry)
- GitHub Actions CI/CD
- Prometheus, Grafana, Alertmanager
- NGINX Ingress Controller
- Trivy for security scanning

---

## ⚙️ Infrastructure Provisioning with Terraform

EKS infrastructure is provisioned using Terraform. The setup includes:

- VPC across 3 availability zones
- EKS cluster & managed node groups
- IAM roles & policies
- Security groups
- S3 backend for Terraform state


```
````

---

## 🚀 Microservices Overview

There are multiple microservices built using Node.js.

Example: `auth` service (`auth/app.js`):

```javascript
const express = require('express');
const client = require('prom-client');
const app = express();
app.use(express.json());

client.collectDefaultMetrics();

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.send(await client.register.metrics());
});

app.get('/auth/health', (req, res) => {
  res.send({ status: 'auth service running' });
});

app.post('/auth/login', (req, res) => {
  const { username, password } = req.body;
  res.send({ token: 'fake-jwt-token', user: username });
});

app.listen(3000, () => console.log('Auth service on port 3000'));
```

---

## 🐳 Docker & ECR

Each microservice is containerized and pushed to AWS ECR.

### Sample Dockerfile

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["node", "app.js"]
```

---

## 🔄 CI/CD with GitHub Actions

Each service has its own `.github/workflows/deploy.yml`.

### Features:

* Build & Push Docker image to ECR
* Trivy Security Scan
* Deploy to EKS

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repo
        uses: actions/checkout@v3

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          region: us-west-2

      - name: Login to ECR
        run: |
          aws ecr get-login-password | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.us-west-2.amazonaws.com

      - name: Build Docker image
        run: |
          docker build -t auth-service .
          docker tag auth-service:latest <aws_account_id>.dkr.ecr.us-west-2.amazonaws.com/auth-service:latest

      - name: Trivy Scan
        uses: aquasecurity/trivy-action@v0.11.2
        with:
          image-ref: 'auth-service:latest'

      - name: Push image to ECR
        run: |
          docker push <aws_account_id>.dkr.ecr.us-west-2.amazonaws.com/auth-service:latest

      - name: Deploy to EKS
        run: |
          kubectl apply -f k8s/deployment.yaml
```

---

## 📦 Kubernetes Manifests

Microservices are deployed using standard `Deployment` and `Service` YAML files.

### Ingress Configuration

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: microservices-ingress
  namespace: devops-apps
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
    - http:
        paths:
          - path: /auth
            pathType: Prefix
            backend:
              service:
                name: auth
                port:
                  number: 80
          - path: /products
            pathType: Prefix
            backend:
              service:
                name: products
                port:
                  number: 80
```

---

## 📈 Monitoring & Alerting

Installed via Helm charts:

* **Prometheus**: Metrics collection
* **Grafana**: Dashboards
* **Alertmanager**: Alerts

### Prometheus Metrics Endpoint

Each service exposes metrics at:

```
/metrics
```

---

## 🛡️ Security Scanning with Trivy

Trivy scans are integrated in the GitHub Actions pipeline.

```yaml
- name: Trivy Scan
  uses: aquasecurity/trivy-action@v0.11.2
  with:
    image-ref: 'auth-service:latest'
```

---

## ✅ Health Checks

Each microservice includes a `/health` endpoint for Kubernetes liveness and readiness probes.

---

## 🧠 Useful Commands

```bash
# Forward Ingress Controller port (if not public)
kubectl port-forward svc/ingress-nginx-controller -n ingress-nginx 8080:80

# Access metrics locally
curl http://localhost:8080/auth/metrics

# Check logs
kubectl logs -f deployment/auth -n devops-apps
```

---

## 📚 Summary

✅ Real microservice architecture
✅ GitHub Actions CI/CD pipeline
✅ Infrastructure-as-Code with Terraform
✅ Container image scan with Trivy
✅ End-to-End monitoring with Prometheus stack
✅ Ingress routing and metrics exposure

---


