# CONSUL Installer

[CONSUL](https://github.com/consul/consul) installer for production environments

Using [Ansible](http://docs.ansible.com/), it will install and configure the following:
 - Ruby
 - Rails
 - Postgres
 - Nginx
 - Unicorn
 - SMTP
 - Memcached
 - DelayedJobs
 - HTTPS
 - Capistrano

It will also create a `deploy` user to install these libraries

## Screencast
[How to setup CONSUL for a production environment](https://public.3.basecamp.com/p/dSTKWbqxtZSaSSpMiYWiqR9U)

## Prerequisities

A remote server with the supported distribution

```
Ubuntu 16.04 x64
```

Access to a remote server via public ssh key without password.
The default user is `deploy` but you can [use any user](#using-a-different-user-than-deploy) with sudo privileges.

```
ssh root@remote-server-ip-address
```

Updated system package versions
```
sudo apt-get update
```

Python 2 installed in the remote server

```
sudo apt-get -y install python-simplejson
```


## No root access

By default the installer assumes you can log in as `root`. The `root` user will only be used once to login and create a `deploy` user. The `deploy` user is the one that will actually install all libraries and is the user that must be used to login to the server to do maintenance tasks.

If you do not have `root` access, you will need your system administrator to grant you: sudo privileges for a `deploy` user in the `wheel` group without password. 

Also you will need to change the variable [root access](https://github.com/consul/installer/compare/no_root_user?expand=1#diff-fc7cb0a7b647c6ff35b553a10d616c4bR11) to `false`.

## Using a different user than deploy

Change the variable [deploy_user](https://github.com/consul/installer/blob/master/group_vars/all#L12) to the username you would like to use.

## Running the installer

The following commands must be executed in your local machine

[Install Ansible >= 2.4](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

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
sudo ansible-playbook -v consul.yml -i hosts
```

Visit remote-server-ip-address

## Admin user

You can sign in to the application with the default admin user:

```
admin@consul.dev
12345678
```

## Other deployment options

### Split database from application code

The [`consul` playbook](consul.yml) creates the database on the same server as the application code. If you are using a cloud host that offers managed databases (such as [AWS RDS](https://aws.amazon.com/rds/), [Azure Databases](https://azure.microsoft.com/en-us/product-categories/databases/), or [Google Cloud SQL](https://cloud.google.com/sql/)), we recommend using that instead.

To set up the application by itself:

1. Fork this repository.
1. Specify your database credentials (see the `database_*` [group variables](group_vars/all)) in a [vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html).
1. Run the [`app` playbook](app.yml) instead of the [`consul`](consul.yml) one against a clean server.

    ```sh
    sudo ansible-playbook -v app.yml -i hosts
    ```

### Platform-as-a-Service (PaaS)

Aside from just using managed databases, you might also look into platform-as-a-service options (like [Azure App Service](https://azure.microsoft.com/en-us/services/app-service/) or [Google App Engine](https://cloud.google.com/appengine/)) to not have to manage a server at all.

## Deploys with Capistrano

### Screencast
[How to setup Capistrano](https://public.3.basecamp.com/p/SxF1BrYFHBZkRWkqVX4NUxGU)

Create your [fork](https://help.github.com/articles/fork-a-repo/)

Setup locally for your [development environment](https://consul_docs.gitbooks.io/docs/content/en/getting_started/local_installation.html))

Uncomment this line in `app.yml` and rerun the installer

```
# - capistrano
```

Run the ansible playbook

```
sudo ansible-playbook -v consul.yml -i hosts
```

Download changes from the `capistrano` branch to your fork

```
git remote add upstream git@github.com:consul/consul.git
git fetch upstream
git merge upstream/capistrano
git push origin master
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
git push origin master
```

Deploy to production

```
cap production deploy
```

You should now see that change at your remote server's ip address

## Email configuration

### Screencast
[How to setup email deliveries](https://public.3.basecamp.com/p/yAGcyJeSVHaW43M7aoHCxu6L)

Update the following file in your production server:
`/home/deploy/consul/shared/config/environments/production.rb`

You want to change this block of code and use your own SMTP credentials:
```
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address:              "smtp.example.com",
    port:                 "25",
    domain:               "your_domain.com or ip address",
    user_name:            "username",
    password:             "password",
    authentication:       "plain",
    enable_starttls_auto: true }
```

And restart the server running this command from your local CONSUL installation (see [Deploys with Capistrano](https://github.com/consul/installer#deploys-with-capistrano) for details).

```
cap production deploy:restart
```

Once you setup your domain, depending on your SMTP provider, you will have to do two things:
- Update the `server_name` with your domain in `/home/deploy/consul/shared/config/secrets.yml`.
- Update the `sender_email_address` from the admin section (`remote-server-ip-address/admin/settings`)

If your SMTP provider uses an authentication other than `plain`, check out the [Rails docs on email configuration](https://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration) for the different authentation options.

## Configuration Variables

These are the main configuration variables:

```
# Server Timzone + Locale
timezone: Europe/Madrid
locale: en_US.UTF-8

# Authorized Hosts
ssh_public_key_path: "change_me/.ssh/id_rsa.pub"

# Ruby
ruby_version: 2.3.2

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

There are many more variables available check them out [here]((https://github.com/consul/installer/blob/master/group_vars/all))
For further configuration and customization options check out the CONSUL [docs](https://consul_docs.gitbooks.io/docs/content/en/customization/introduction.html)

## Ansible Documentation

http://docs.ansible.com/

## Roadmap
Cross platform compatibility (Ubuntu, CentOS)

Greater diversity of interchangeable roles (nginx/apache, unicorn/puma/passenger, rvm/rbenv)

## How to contribute
- Open an issue
- Send us a Pull Request

## Support

[![Join the chat at https://gitter.im/consul/consul](https://badges.gitter.im/consul/consul.svg)](https://gitter.im/consul/consul?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

## License

Code published under AFFERO GPL v3 (see [LICENSE-AGPLv3.txt](LICENSE-AGPLv3.txt))
