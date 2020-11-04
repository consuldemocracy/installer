# CONSUL Installer [![Build Status](https://travis-ci.com/consul/installer.svg?branch=master)](https://travis-ci.com/consul/installer)

[CONSUL](https://github.com/consul/consul) installer for production environments

Using [Ansible](http://docs.ansible.com/), it will install and configure the following:

- Ruby
- Rails
- Postgres
- Nginx
- Puma
- SMTP
- Memcached
- DelayedJobs
- HTTPS
- Capistrano

It will also create a `deploy` user to install these libraries

## Screencast

[How to setup CONSUL for a production environment](https://youtu.be/1lvnjDuRFzw)

## Prerequisities

A remote server with one of the supported distributions:

- Ubuntu 16.04 x64
- Ubuntu 18.04 x64

Access to a remote server via public ssh key without password.
The default user is `deploy` but you can [use any user](#using-a-different-user-than-deploy) with sudo privileges.

```
ssh root@remote-server-ip-address
```

Updated system package versions

```
sudo apt-get update
```

Python 3 installed in the remote server

## Running the installer

The following commands must be executed in your local machine

[Install Ansible >= 2.7](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

Get the Ansible Playbook

```
git clone https://github.com/consul/installer
cd installer
```

Create your local `hosts` file

```
cp hosts.example hosts
```

Update your local `hosts` file with the remote server's ip address

```
remote-server-ip-address (maintain other default options)
```

Run the ansible playbook

```
ansible-playbook -v consul.yml -i hosts
```

Note about old versions: if you've already used the installer before version 1.1 was released, you might need to remove your `~/.ansible` folder.

Visit remote-server-ip-address in your browser and you should see CONSUL running!

## Admin user

You can sign in to the application with the default admin user:

```
admin@consul.dev
12345678
```

## Deploys with Capistrano

To restart the server and deploy new code to the server we have to configure Capistrano.

### Screencast

[How to setup Capistrano](https://youtu.be/ZCfPz_c_H6g)

Create your [fork](https://help.github.com/articles/fork-a-repo/)

Setup locally for your [development environment](https://docs.consulproject.org/docs/english-documentation/introduction/local_installation)

Checkout the latest stable version:

```
git checkout origin/1.2.0 -b stable
```

Create your `deploy-secrets.yml`

```
cp config/deploy-secrets.yml.example config/deploy-secrets.yml
```

Update `deploy-secrets.yml` with your server's info

```
deploy_to: "/home/deploy/consul"
server1: "your_remote_ip_address"
db_server: "localhost"
server_name: "your_remote_ip_address"
```

Update your `repo_url` in `deploy.rb`

```
set :repo_url, 'https://github.com/your_github_username/consul.git'
```

Make a change in a view and push it your fork in Github

```
git add .
git commit -a -m "Add sample text to homepage"
git push origin stable
```

Deploy to production

```
branch=stable cap production deploy
```

You should now see that change at your remote server's ip address

## Email configuration

### Screencast

[How to setup email deliveries](https://youtu.be/9W6txGpe4v4)

Screencast update: The Installer now configures a queue to send emails asynchronously. Thus you will not see a 500 error when there is a misconfiguration, as the email is sent asyncronously and the error will be raised in the queue. To see email error logs open the rails console (`cd /home/deploy/consul/current/ && bin/rails c -e production`) and search for the last error in the queue `Delayed::Job.last.last_error`)

Update the following file in your production server:
`/home/deploy/consul/shared/config/secrets.yml`

You want to change this block of code for your production environment and use your own SMTP credentials:

```
  mailer_delivery_method: "smtp"
  smtp_settings:
    address:              "smtp.example.com"
    port:                 "25"
    domain:               "your_domain.com"
    user_name:            "username"
    password:             "password"
    authentication:       "plain"
    enable_starttls_auto: true
```

And restart the server running this command from your local CONSUL installation (see [Deploys with Capistrano](https://github.com/consul/installer#deploys-with-capistrano) for details).

```
cap production deploy:restart
```

Once you setup your domain, depending on your SMTP provider, you will have to do two things:

- Update the `server_name` with your domain in `/home/deploy/consul/shared/config/secrets.yml`.
- Update the `sender_email_address` from the admin section (`remote-server-ip-address/admin/settings`)

If your SMTP provider uses an authentication other than `plain`, check out the [Rails docs on email configuration](https://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration) for the different authentation options.

## Staging server

To setup a staging server to try things out before deploying to a production server:

Update your local `hosts` file with the staging server's ip address

```
remote-server-ip-address (maintain other default options)
```

And run the playbook with an extra var "env":

```
ansible-playbook -v consul.yml --extra-vars "env=staging" -i hosts
```

Visit remote-server-ip-address in your browser and you should now see CONSUL running in your staging server.

## SSL with LetsEncrypt

Using https instead of http is an important security configuration. Before you begin, you will need to either buy a domain or get access to the configuration of an existing domain. Next, you need to make sure you have an A Record in the DNS configuration of your domain, pointing to the correponding IP address of your server. You can check if your domain is correctly configured at this url https://dnschecker.org/, where you should see your IP address when searching for your domain name.

Once you have that setup we need to configure the Installer to use your domain in the application.

First, uncomment the `domain` variable in the [configuration file](https://github.com/consul/installer/blob/1.2.0/group_vars/all) and update it with your domain name:

```
#domain: "your_domain.com"
```

Next, uncomment the `letsencrypt_email` variable in the [configuration file](https://github.com/consul/installer/blob/1.2.0/group_vars/all) and update it with a valid email address:

```
#letsencrypt_email: "your_email@example.com"
```

Re-run the installer:

```
ansible-playbook -v consul.yml -i hosts
```

You should now be able to see the application running at https://your_domain.com in your browser.

## Configuration Variables

These are the main configuration variables:

```
# Server Timzone + Locale
timezone: Europe/Madrid
locale: en_US.UTF-8

# Authorized Hosts
ssh_public_key_path: "change_me/.ssh/id_rsa.pub"

#Postgresql
postgresql_version: 9.6
database_name: "consul_production"
database_user: "deploy"
database_password: "change_me"
database_hostname: "localhost"
database_port: 5432

#SMTP
smtp_address:        "smtp.example.com"
smtp_port:           25
smtp_domain:         "your_domain.com"
smtp_user_name:      "username"
smtp_password:       "password"
smtp_authentication: "plain"
```

There are many more variables available check them out [here]((https://github.com/consul/installer/blob/1.2.0/group_vars/all))

## Other deployment options

### Split database from application code

The [`consul` playbook](consul.yml) creates the database on the same server as the application code. If you are using a cloud host that offers managed databases (such as [AWS RDS](https://aws.amazon.com/rds/), [Azure Databases](https://azure.microsoft.com/en-us/product-categories/databases/), or [Google Cloud SQL](https://cloud.google.com/sql/)), we recommend using that instead.

To set up the application by itself:

1. Fork this repository.
1. Specify your database credentials (see the `database_*` [group variables](group_vars/all)) in a [vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html).
1. Run the [`app` playbook](app.yml) instead of the [`consul`](consul.yml) one against a clean server.

```sh
ansible-playbook -v app.yml -i hosts
```

### Platform-as-a-Service (PaaS)

Aside from just using managed databases, you might also look into platform-as-a-service options (like [Azure App Service](https://azure.microsoft.com/en-us/services/app-service/) or [Google App Engine](https://cloud.google.com/appengine/)) to not have to manage a server at all.

## No root access

By default the installer assumes you can log in as `root`. The `root` user will only be used once to login and create a `deploy` user. The `deploy` user is the one that will actually install all libraries and is the user that must be used to login to the server to do maintenance tasks.

If you do not have `root` access, you will need your system administrator to grant you sudo privileges for a `deploy` user in the `wheel` group without password. You will also need to change the variable `ansible_user` to `deploy` in your `hosts` file.

## Using a different user than deploy

Change the variable [deploy_user](https://github.com/consul/installer/blob/1.2.0/group_vars/all#L12) to the username you would like to use.

## Ansible Documentation

http://docs.ansible.com/

## Roadmap

Cross platform compatibility (Ubuntu, CentOS)

Greater diversity of interchangeable roles (nginx/apache, unicorn/puma/passenger, rvm/rbenv)

## How to contribute

- [Open an issue](https://help.github.com/en/articles/creating-an-issue)
- [Send us a Pull Request](https://help.github.com/en/articles/creating-a-pull-request)

## Support

[![Join the chat at https://gitter.im/consul/consul](https://badges.gitter.im/consul/consul.svg)](https://gitter.im/consul/consul?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

## License

Code published under AFFERO GPL v3 (see [LICENSE-AGPLv3.txt](LICENSE-AGPLv3.txt))
