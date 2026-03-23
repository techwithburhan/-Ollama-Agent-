## 🚀 Getting Started

Follow these instructions to get a copy of the project up and running on your local machine using Docker.

### Prerequisites

  * [Docker](https://docs.docker.com/get-docker/) installed and running on your system.

### 🐳 Installation & Run Commands

**1. Navigate to the Frontend Directory**

```bash
cd ollama-agent/frontend
```

**2. Build the Docker Image**

```bash
docker build -t ollama-agent-frontend .
```
```code
[+] Building 58.8s (18/18) FINISHED                                                               docker:desktop-linux
 => [internal] load build definition from Dockerfile                                                              0.0s
 => => transferring dockerfile: 1.57kB                                                                            0.0s
 => [internal] load metadata for docker.io/library/node:18-alpine                                                30.9s
 => [internal] load metadata for docker.io/library/nginx:1.25-alpine                                             30.9s
 => [auth] library/node:pull token for registry-1.docker.io                                                       0.0s
 => [auth] library/nginx:pull token for registry-1.docker.io                                                      0.0s
 => [internal] load .dockerignore                                                                                 0.1s
 => => transferring context: 2B                                                                                   0.0s
 => [builder 1/6] FROM docker.io/library/node:18-alpine@sha256:8d6421d663b4c28fd3ebc498332f249011d118945588d0a35  7.2s
 => => resolve docker.io/library/node:18-alpine@sha256:8d6421d663b4c28fd3ebc498332f249011d118945588d0a35cb9bc4b8  0.0s
 => => sha256:02bb84e9f3412827f177bc6c020812249b32a8425d2c1858e9d71bd4c015f031 443B / 443B                        0.8s
 => => sha256:d84c815451acbca96b6e6bdb479929222bec57121dfe10cc5b128c5c2dbaf10a 39.66MB / 39.66MB                  6.8s
 => => sha256:8bfa36aa66ce614f6da68a16fb71f875da8d623310f0cb80ae1ecfa092f587f6 1.26MB / 1.26MB                    2.1s
 => => sha256:6e771e15690e2fabf2332d3a3b744495411d6e0b00b2aea64419b58b0066cf81 3.99MB / 3.99MB                    2.4s
 => => extracting sha256:6e771e15690e2fabf2332d3a3b744495411d6e0b00b2aea64419b58b0066cf81                         0.1s
 => => extracting sha256:d84c815451acbca96b6e6bdb479929222bec57121dfe10cc5b128c5c2dbaf10a                         0.4s
 => => extracting sha256:8bfa36aa66ce614f6da68a16fb71f875da8d623310f0cb80ae1ecfa092f587f6                         0.0s
 => => extracting sha256:02bb84e9f3412827f177bc6c020812249b32a8425d2c1858e9d71bd4c015f031                         0.0s
 => [production 1/4] FROM docker.io/library/nginx:1.25-alpine@sha256:516475cc129da42866742567714ddc681e5eed7b9ee  8.6s
 => => resolve docker.io/library/nginx:1.25-alpine@sha256:516475cc129da42866742567714ddc681e5eed7b9ee0b9e9c015e4  0.0s
 => => sha256:4f6b4e3940df0e5a4b975a6943afdcd034a2a0e2404258436cc76fd145d04d0c 12.92MB / 12.92MB                  4.0s
 => => sha256:98ff282c446606ae80b6c7812c9248a7b9d56f86b18c0b9b068ba821517cdb66 1.40kB / 1.40kB                    1.2s
 => => sha256:182e691fb2cc710f857dcd9016d4854cea790a28508e33bf2ef928f61ae6c4d6 1.21kB / 1.21kB                    1.3s
 => => sha256:166b80e00f74c3a053c98236bd987af4ee91e23276257bf52858ebc900d55bb3 394B / 394B                        0.9s
 => => sha256:b4f3127eb6227853129ee22d81700ccf48bcdcb17929680fc9f01ac3c7bc6dbd 957B / 957B                        0.9s
 => => sha256:a83296a673ce8848db1a03260b4104984c299b3619a73842eeecb887e6ebd1c0 627B / 627B                        0.8s
 => => sha256:ddf9db5a05cbf61e62d46b1225986f3238390e770aedf7c3633b0f4984df6a6b 3.90MB / 3.90MB                    1.6s
 => => sha256:bca4290a96390d7a6fc6f2f9929370d06f8dfcacba591c76e3d5c5044e7f420c 3.35MB / 3.35MB                    3.5s
 => => extracting sha256:bca4290a96390d7a6fc6f2f9929370d06f8dfcacba591c76e3d5c5044e7f420c                         0.0s
 => => extracting sha256:ddf9db5a05cbf61e62d46b1225986f3238390e770aedf7c3633b0f4984df6a6b                         0.1s
 => => extracting sha256:a83296a673ce8848db1a03260b4104984c299b3619a73842eeecb887e6ebd1c0                         0.0s
 => => extracting sha256:b4f3127eb6227853129ee22d81700ccf48bcdcb17929680fc9f01ac3c7bc6dbd                         0.0s
 => => extracting sha256:166b80e00f74c3a053c98236bd987af4ee91e23276257bf52858ebc900d55bb3                         0.0s
 => => extracting sha256:182e691fb2cc710f857dcd9016d4854cea790a28508e33bf2ef928f61ae6c4d6                         0.0s
 => => extracting sha256:98ff282c446606ae80b6c7812c9248a7b9d56f86b18c0b9b068ba821517cdb66                         0.0s
 => => extracting sha256:4f6b4e3940df0e5a4b975a6943afdcd034a2a0e2404258436cc76fd145d04d0c                         0.1s
 => [internal] load build context                                                                                 0.0s
 => => transferring context: 904.26kB                                                                             0.0s
 => [builder 2/6] WORKDIR /app                                                                                    0.1s
 => [builder 3/6] COPY package*.json ./                                                                           0.0s
 => [builder 4/6] RUN npm install --legacy-peer-deps                                                             15.7s
 => [production 2/4] RUN rm /etc/nginx/conf.d/default.conf                                                        0.1s
 => [production 3/4] COPY nginx.conf /etc/nginx/conf.d/default.conf                                               0.0s
 => [builder 5/6] COPY . .                                                                                        0.1s
 => [builder 6/6] RUN npm run build                                                                               4.3s
 => [production 4/4] COPY --from=builder /app/build /usr/share/nginx/html                                         0.0s
 => exporting to image                                                                                            0.1s
 => => exporting layers                                                                                           0.1s
 => => exporting manifest sha256:fcb030a168c82af08a50028edd58751846ac549c14944af8273378ade4b4ee52                 0.0s
 => => exporting config sha256:afa392d51d5695641182ff918de6787934adcc8bcdac9d0984169334adebc7cc                   0.0s
 => => exporting attestation manifest sha256:ed12fb629af03aa8f1ca4cb905daa1c6fc522a671df9534d2fbe695db8dc521c     0.0s
 => => exporting manifest list sha256:49549ac2f8000bb7b5f0b331e4b2b5c7da211b180ee3aac233420201ca2bedbd            0.0s
 => => naming to docker.io/library/ollama-agent-frontend:latest                                                   0.0s
 => => unpacking to docker.io/library/ollama-agent-frontend:latest                                                0.0s
```
<img width="1347" height="619" alt="Screenshot 2026-03-23 at 11 36 47 PM" src="https://github.com/user-attachments/assets/24548ddf-1965-4811-90ad-69e821ea39c1" />

**3. Run the Docker Container**

```bash
docker run -d -p 3000:80 ollama-agent-frontend
```

**4. Access the Application**
Open your browser and visit:
👉 **[http://localhost:3000](https://www.google.com/search?q=http://localhost:3000)**

> **Note:** The container serves the production build using Nginx on internal port 80. If port `3000` is already in use on your host machine, you can map it to a different port:
>
> ```bash
> docker run -d -p 3001:80 ollama-agent-frontend
> ```

-----

## ⚙️ Environment Variables

The following environment variables were primarily used during local development (`npm start`) and are **not required** for the Docker production build. They can be safely ignored in the Docker setup:

| Variable | Usage | Status in Docker |
| :--- | :--- | :--- |
| `DANGEROUSLY_DISABLE_HOST_CHECK` | Disables host checking (dev only) | ❌ Ignored |
| `WDS_SOCKET_HOST` | Webpack dev server config | ❌ Ignored |
| `WDS_SOCKET_PORT` | Webpack dev server config | ❌ Ignored |
| `HOST` | Local binding configuration | ❌ Ignored |

-----

## 📦 Tech Stack

  * **Frontend Framework:** React.js
  * **Containerization:** Docker
  * **Web Server:** Nginx

-----

## 🌐 Advanced Deployment (Future Scope)

As the project scales, this containerized frontend is fully ready to be integrated into broader architectures:

  * **Kubernetes:** Deployable via standard `Deployment` and `Service` manifests.
  * **AWS:** Ready for deployment on Amazon ECS, EKS, or EC2 instances behind an Application Load Balancer.
  * **CI/CD:** Easily integratable into Jenkins or GitHub Actions pipelines for automated builds.

-----

## 📌 Author

**Burhan**
🚀 *Tech with Burhan* \`\`\`

Ekdum set hai\! 🚀 Would you like me to also draft a quick `docker-compose.yml` file or a Kubernetes `deployment.yaml` file so you can take this frontend setup to the next level?
