# 🚀 n8n On-Premise Solution

[![n8n](https://img.shields.io/badge/n8n-workflow-blue.svg)](https://n8n.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> **Empower your team with a self-hosted, powerful workflow automation platform.**

## 💡 For Non-Technical Users

**Imagine having a personal digital assistant that can connect all your apps, automate repetitive tasks, and streamline your operations—all running securely on your own infrastructure.**

🔍 **The Problem**: You have repetitive digital tasks that eat up hours of your time - sending emails, processing data, managing customer interactions, or integrating different business tools. Relying on cloud-based solutions might raise concerns about data privacy, security, or vendor lock-in.

✨ **The Solution**: n8n is a powerful workflow automation tool that helps you connect different apps and services together without writing code. This repository provides a simple, one-click way to run n8n on your own computer or server using Docker. Instead of complex installation steps, you just run a single command, and you're ready to start automating your workflows!

### Real Examples
- **You need**: "Automatically send a welcome email to new sign-ups from my website and add them to my CRM."
- **n8n does**: Connects your website form to your email marketing tool and CRM, automating the entire onboarding sequence.

- **You need**: "Sync customer data between my e-commerce platform and my accounting software daily."
- **n8n does**: Connects both platforms, extracts new orders/customer data, and updates your accounting system automatically.

**Perfect for**: Small businesses, developers, data analysts, or anyone who wants to automate boring digital tasks, maintain full control over their data, and ensure privacy.

## ⚡ What Makes This Special

- ⚙️ **Self-Hosted Control** - Your data stays on your servers, ensuring maximum privacy and security.
- 🐳 **Docker-Powered Simplicity** - Easy, one-click setup with Docker, no complex configurations.
- 📊 **Powerful Workflow Automation** - Connect hundreds of apps and services with a visual editor.
- 🛡️ **Secure & Configurable** - Comes with security best practices and flexible environment variables.
- 🔄 **Easy Management** - Simple scripts for starting, stopping, restarting, and updating your n8n instance.
- 💾 **Persistent Data Storage** - All your workflows and data are safely stored in a local PostgreSQL database.

## 🚀 Quick Start

### What You Need
- [Docker Desktop](https://www.docker.com/products/docker-desktop) installed and running.
- [Git](https://git-scm.com/) for cloning the repository.

### Setup (3 minutes)
```bash
# 1. Download the code
git clone https://github.com/madebypatrik/n8n-docker.git
cd n8n-docker

# 2. Copy and configure environment variables
cp .env.example .env
# Edit .env file with your preferred settings
# IMPORTANT: Change N8N_BASIC_AUTH_PASSWORD to a strong, unique password!

# 3. Start n8n
./scripts/start.sh
```

### Access n8n
1. Open your browser and go to: `http://localhost:5678`
2. On your first visit, you'll be prompted to create an owner account.
3. Enter your email, first name, last name, and create a password. This will be your main admin account for n8n.

**You're now ready to build your first workflow!**

## 📁 Project Structure

```
n8n-docker/
├── docker-compose.yml          # Main Docker Compose configuration
├── .env.example               # Environment variables template
├── scripts/
│   ├── start.sh              # Start n8n services
│   ├── stop.sh               # Stop n8n services
│   ├── restart.sh            # Restart n8n services
│   ├── logs.sh               # View logs
│   ├── update.sh             # Update to latest n8n version
│   ├── status.sh             # Comprehensive status check
│   └── monitor.sh            # Real-time monitoring
├── docs/
│   ├── configuration.md      # Detailed configuration guide
│   └── troubleshooting.md    # Common issues and solutions
└── README.md                 # This file
```

## 🛠️ Management Scripts

### Start Services
```bash
./scripts/start.sh
```

### Stop Services
```bash
./scripts/stop.sh
```

### Restart Services
```bash
./scripts/restart.sh
```

### View Logs
```bash
./scripts/logs.sh [service-name]
```

### Update n8n
```bash
./scripts/update.sh
```

### Comprehensive Status Check
```bash
./scripts/status.sh
```

## ⚙️ Configuration

### Environment Variables

Key environment variables you can customize in `.env`:

| Variable                 | Description                                      | Default                         |
|--------------------------|--------------------------------------------------|---------------------------------|
| `N8N_PORT`               | Port for n8n web interface                       | `5678`                          |
| `N8N_BASIC_AUTH_USER`    | Basic authentication username                    | `admin`                         |
| `N8N_BASIC_AUTH_PASSWORD`| Basic authentication password ( **CHANGE THIS** ) | `your-secure-password`          |
| `POSTGRES_DB`            | PostgreSQL database name                         | `n8n`                           |
| `POSTGRES_USER`          | PostgreSQL username                              | `n8n`                           |
| `POSTGRES_PASSWORD`      | PostgreSQL password                              | *Generated (change for prod)*   |

### Docker Compose Services

- **n8n**: The main n8n application container.
- **postgres**: A PostgreSQL database container for n8n's data persistence.

## 🔒 Security Considerations

- **Change Default Passwords**: Always update `N8N_BASIC_AUTH_PASSWORD` and `POSTGRES_PASSWORD` in your `.env` file to strong, unique values.
- **Production Passwords**: For production deployments, use robust, randomly generated passwords for all credentials.
- **SSL/TLS**: Implement SSL/TLS (e.g., via a reverse proxy like Nginx or Traefik) for encrypted communication in production environments.
- **Regular Updates**: Keep your n8n instance and Docker images up-to-date by regularly running `./scripts/update.sh`.

## 🚀 Production Deployment

For deploying n8n in a production environment, consider the following best practices:

1.  **SSL/TLS**: Set up a reverse proxy (Nginx, Traefik) to handle SSL/TLS termination and secure your n8n instance with HTTPS.
2.  **Automated Backups**: Implement a strategy for regular, automated backups of your PostgreSQL database volume.
3.  **Monitoring**: Integrate with a monitoring solution (e.g., Prometheus, Grafana) to keep an eye on n8n's performance and health.
4.  **Secrets Management**: For sensitive credentials, use Docker secrets or an external secrets management system instead of directly in the `.env` file.
5.  **Dedicated Resources**: Allocate sufficient CPU, memory, and disk I/O for optimal n8n performance.

## 🤝 Contributing

Found this useful? Contributions are welcome!
1.  Fork the repository.
2.  Create your feature branch (`git checkout -b feature/your-feature-name`).
3.  Commit your changes (`git commit -m 'Add your feature'`).
4.  Push to the branch (`git push origin feature/your-feature-name`).
5.  Open a Pull Request.

## 📄 License

MIT License - Free to use and modify. See the [LICENSE](LICENSE) file for details.

## 🙏 Built With

-   [n8n.io](https://n8n.io/) - The amazing workflow automation platform.
-   [Docker](https://www.docker.com/) - For containerization and easy deployment.
-   [PostgreSQL](https://www.postgresql.org/) - The robust relational database.

---

⭐ **Star this repo if it helps you automate your workflows!**

*Built by [@madebypatrik](https://github.com/madebypatrik) - Simplifying on-premise automation.*

**⚠️ Note**: Use responsibly. Ensure you comply with all applicable laws and terms of service when automating interactions with third-party services. This solution is designed for self-hosting and gives you full control over your data.