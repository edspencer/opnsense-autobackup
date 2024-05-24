# OPNsense Auto Backup Docker Container

This Docker container automates the process of downloading backups from an OPNsense firewall and pushing them to a GitHub repository. The container can run an immediate backup or operate with a cron schedule to ensure regular backups.

There is more context in my blog post at https://edspencer.net/2024/05/28/automating-opnsense-backups. This is intended to be a starting point for your own custom requirements.

## Features

- Downloads OPNsense backups using a CURL command.
- Pushes the backups to a specified GitHub repository.
- Supports environment variables for configuration.
- Optional file naming with the current date.
- Configurable cron schedule.

## Prerequisites

- Docker installed on your machine.
- A GitHub repository to store the backups.
- GitHub personal access token with repository access.

## Environment Variables

You need to create a `.env` file with the following environment variables (duplicate the .env.example file for an easy start):

```env
API_KEY=your_actual_api_key
API_SECRET=your_actual_api_secret
HOSTNAME=firewall.local
GIT_REPO_URL=https://github.com/your_username/your_repo.git
GIT_USERNAME=your_actual_git_username
GIT_EMAIL=your_actual_git_email
GIT_TOKEN=your_actual_git_token
CRON_SCHEDULE="0 0 * * *"  # Optional: only required for cron mode
```

- **API_KEY**: Your OPNsense API key.
- **API_SECRET**: Your OPNsense API secret.
- **HOSTNAME**: The hostname of your OPNsense firewall.
- **GIT_REPO_URL**: The URL of your GitHub repository.
- **GIT_USERNAME**: Your GitHub username.
- **GIT_EMAIL**: Your GitHub email.
- **GIT_TOKEN**: Your GitHub personal access token.
- **CRON_SCHEDULE**: The cron schedule for running the backup (optional, e.g., "0 0 \* \* \*" for daily at midnight).

## Usage

### Run the Container

#### Immediate Backup

To run the container and perform an immediate backup, omit the `CRON_SCHEDULE` environment variable:

```sh
docker run --rm   -e API_KEY="your_actual_api_key"   -e API_SECRET="your_actual_api_secret"   -e HOSTNAME="firewall.local"   -e GIT_REPO_URL="https://github.com/your_username/your_repo.git"   -e GIT_USERNAME="your_actual_git_username"   -e GIT_EMAIL="your_actual_git_email"   -e GIT_TOKEN="your_actual_git_token"   edspencer/opnsense-autobackup:latest
```

#### Cron Mode

To run the container with a cron schedule, set the `CRON_SCHEDULE` environment variable:

```sh
docker run --rm   -e API_KEY="your_actual_api_key"   -e API_SECRET="your_actual_api_secret"   -e HOSTNAME="firewall.local"   -e GIT_REPO_URL="https://github.com/your_username/your_repo.git"   -e GIT_USERNAME="your_actual_git_username"   -e GIT_EMAIL="your_actual_git_email"   -e GIT_TOKEN="your_actual_git_token"   -e CRON_SCHEDULE="0 0 * * *"   edspencer/opnsense-autobackup:latest
```

## How It Works

1. **Clone the Repository**:
   The container clones the specified GitHub repository into `/repo`.

2. **Download the Backup**:
   The container uses CURL to download the backup from the OPNsense firewall and saves it as `latest.xml`.

3. **Save the Backup with Date**:
   The container saves another copy of the backup with the current date, e.g., `backup_2024-11-11.xml`.

4. **Commit and Push**:
   The container commits the backup files to the GitHub repository with a commit message that includes the current date and pushes the changes.

## Example `.env` File

Here is an example `.env` file:

```env
API_KEY=your_actual_api_key
API_SECRET=your_actual_api_secret
HOSTNAME=firewall.local
GIT_REPO_URL=https://github.com/your_username/your_repo.git
GIT_USERNAME=your_actual_git_username
GIT_EMAIL=your_actual_git_email
GIT_TOKEN=your_actual_git_token
CRON_SCHEDULE="0 0 * * *"  # Optional: only required for cron mode
```

## Running on TrueNAS SCALE with Configurable Cron Schedule

This Docker container includes a built-in cron job to automate the backup process. The cron schedule is configurable via an environment variable, and is required in the context of TrueNAS otherwise the container will execute in immediate backup mode and then exit, causing TrueNAS to continually restart it incorrectly.

Follow these steps to deploy it on TrueNAS SCALE:

1. **Open TrueNAS SCALE Web Interface**:

   - Navigate to your TrueNAS SCALE web interface.

2. **Go to Apps Section**:

   - Click on "Apps" in the sidebar.

3. **Launch Docker Image**:

   - Click on "Launch Docker Image".

4. **Enter Docker Image Details**:

   - **Image Repository**: `edspencer/opnsense-autobackup`
   - **Image Tag**: `latest`

5. **Configure Environment Variables**:

   - Scroll down to the "Variables" section and add the environment variables from your `.env` file. For each variable, click "Add" and enter the name and value.

   | Name          | Value                                            |
   | ------------- | ------------------------------------------------ |
   | API_KEY       | `your_actual_api_key`                            |
   | API_SECRET    | `your_actual_api_secret`                         |
   | HOSTNAME      | `firewall.local`                                 |
   | GIT_REPO_URL  | `https://github.com/your_username/your_repo.git` |
   | GIT_USERNAME  | `your_actual_git_username`                       |
   | GIT_EMAIL     | `your_actual_git_email`                          |
   | GIT_TOKEN     | `your_actual_git_token`                          |
   | CRON_SCHEDULE | `0 0 * * *`                                      |

6. **Deploy the App**:
   - Click on "Launch" to deploy the Docker container.

### How It Works

- The Docker container uses `cron` to schedule the backup script to run at the interval specified by the `CRON_SCHEDULE` environment variable.
- The container runs the initial backup immediately upon startup.
- The container stays alive, running the `cron` service in the foreground to ensure scheduled backups.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

If you have any suggestions or improvements, feel free to submit a pull request or open an issue.

## Acknowledgements

- [OPNsense](https://opnsense.org/)
- [Docker](https://www.docker.com/)
- [GitHub](https://github.com/)
