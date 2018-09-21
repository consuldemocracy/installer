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

Root ssh access to the remote server with a public ssh key

```
ssh root@remote-server-ip-address
```

Python 2 installed in the remote server

```
sudo apt-get -y install python-simplejson
```


## Running the installer
    
The following commands are to be executed in your local machine

Ansible >= 2.4

```
brew install ansible
```

Python

```
easy_install simplejson
```

Playbook

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
[servers]
remote-server-ip-address (maintain other default options)
```

Run the ansible playbook
    
```
sudo ansible-playbook -v consul.yml -i hosts --extra-vars "target=servers"
```

Visit remote-server-ip-address

## Admin user

You can sign in to the application with the default admin user:

```
admin@consul.dev
12345678
```

## Email configuration

Update the following local [configuration variables](https://github.com/consul/installer/blob/master/group_vars/all) and rerun the ansible playbook
```
server_hostname: remote_server_ip_address_or_domain_name

smtp_address:        "smtp.example.com"
smtp_port:           25
smtp_domain:         "your_domain.com"
smtp_user_name:      "username"
smtp_password:       "password"
smtp_authentication: "plain"
```

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

## Deploys with Capistrano

## Screencast
[How to setup Capistrano](https://public.3.basecamp.com/p/SxF1BrYFHBZkRWkqVX4NUxGU)

Create your [fork](https://help.github.com/articles/fork-a-repo/)

Setup locally for your [development environment](https://github.com/consul/consul#configuration-for-development-and-test-environments)

Uncomment this line in `consul.yml` and rerun the installer
    
```
# - capistrano
```

Run the ansible playbook
    
```
sudo ansible-playbook -v consul.yml -i hosts --extra-vars "target=servers"
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