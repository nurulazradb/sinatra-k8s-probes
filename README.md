# Sinatra Microservice with Kubernetes Probes

This project demonstrates a simple Sinatra microservice equipped with liveness, readiness, and startup probes, designed to be deployed on Kubernetes.

## Prerequisites

*   Ruby (version specified in `Gemfile`, e.g., 3.3.x)
*   Bundler
*   Docker
*   Kubernetes cluster (e.g., Minikube, Kind, Docker Desktop Kubernetes)
*   `kubectl` command-line tool

## Project Structure

```
.
├── Dockerfile
├── Gemfile
├── Gemfile.lock
├── app.rb             # Main Sinatra application file
├── config/
│   └── database.rb    # Database configuration
├── deployment.yaml    # Kubernetes Deployment manifest
├── lib/
│   └── startup_manager.rb # Manages startup state
├── routes/
│   ├── health_routes.rb
│   ├── readiness_routes.rb
│   └── startup_routes.rb
└── test/                # Unit tests (optional)
```

## API Endpoints

The application exposes the following endpoints on port `4567`:

*   `GET /`: Returns a welcome message.
    *   Example: `curl http://localhost:4567/`
*   `GET /health`: Liveness probe endpoint. Returns `200 OK` if the application is healthy, `503 Service Unavailable` otherwise.
    *   Example: `curl http://localhost:4567/health`
*   `PUT /health_status`: Toggles the `/health` endpoint status.
    *   Example (set to down): `curl -X PUT -H "Content-Type: application/json" -d '{"status":"down"}' http://localhost:4567/health_status`
    *   Example (set to up): `curl -X PUT -H "Content-Type: application/json" -d '{"status":"up"}' http://localhost:4567/health_status`
*   `GET /ready`: Readiness probe endpoint. Returns `200 OK` if the application is ready to serve traffic (e.g., database connected), `503 Service Unavailable` otherwise.
    *   Example: `curl http://localhost:4567/ready`
*   `GET /startup`: Startup probe endpoint. Returns `200 OK` once the application's initial startup tasks are complete, `503 Service Unavailable` during startup.
    *   Example: `curl http://localhost:4567/startup`

## Local Development (Optional)

1.  Install dependencies:
    ```bash
    bundle install
    ```
2.  Run the application:
    ```bash
    bundle exec ruby app.rb
    ```
    The application will be available at `http://localhost:4567`.

## Building the Docker Image

1.  Navigate to the project root directory.
2.  Build the Docker image:
    ```bash
    docker build -t sinatra-k8s-probes:latest .
    ```
    This command uses the `Dockerfile` to build an image named `sinatra-k8s-probes` with the tag `latest`.

## Deploying to Kubernetes

1.  **Ensure your Kubernetes cluster is running.**

2.  **Load the local Docker image into your cluster (if necessary).**
    *   For Minikube:
        ```bash
        minikube image load sinatra-k8s-probes:latest
        ```
    *   For Kind:
        ```bash
        kind load docker-image sinatra-k8s-probes:latest --name <your-kind-cluster-name>
        ```
    *   For Docker Desktop Kubernetes, images built locally are often available directly if you're using the Docker daemon integrated with Kubernetes.
    *   The `imagePullPolicy: Never` in `deployment.yaml` tells Kubernetes to use the local image.

3.  **Apply the Kubernetes deployment manifest:**
    ```bash
    kubectl apply -f deployment.yaml
    ```
    This will create a Deployment named `sinatra-probes-deployment`.

4.  **Check the status of the deployment and pods:**
    ```bash
    kubectl get deployments
    kubectl get pods
    ```
    Wait for the pod(s) to be in the `Running` state and `1/1` in the `READY` column.

5.  **View pod logs (for troubleshooting):**
    ```bash
    kubectl logs -f <your-pod-name> -c sinatra-probes-container
    ```
    Replace `<your-pod-name>` with the actual name of your pod (e.g., `sinatra-probes-deployment-xxxxxxxxx-yyyyy`).

## Accessing the Service in Kubernetes

To access the application running in your Kubernetes cluster from your local machine, you can use `kubectl port-forward`:

```bash
kubectl port-forward deployment/sinatra-probes-deployment 8080:4567
```

This command forwards port `8080` on your local machine to port `4567` on one of the pods managed by the `sinatra-probes-deployment`.

You can then access the application in your browser or with `curl` at `http://localhost:8080`. For example:

```bash
curl http://localhost:8080/
curl http://localhost:8080/health
```

For more permanent or external access, you would typically create a Kubernetes `Service` object (e.g., of type `LoadBalancer` or `NodePort`). `port-forward` is convenient for development and testing.