準備
======

github.comからchef-repoをダウンロードする

        $ git clone git://github.com/opscode/chef-repo.git

----

https://manage.opscode.comから二つのpemファイルをダウンロードしてから  
knife.rbファイルを生成する。chef-repo/.chefディレクトリに配置する  

----

knifeコマンドがインストールされていることを確認する

        $ knife --version
        Chef: 11.14.6

----

リモートのChefサーバにあるクライアントリストを表示する

        $ knife client list

        tera-validator
----

knifeでbootstrapを実行する。bootstrapの目的はnodeにchef-clientをインストールして、  
リモートのChef サーバーにnode1という名前のこのnodeを登録する。  

        $ knife bootstrap localhost --sudo -x vagrant -P vagrant --ssh-port 2222 -N node1

上のコマンドのport 2222はどこから来ているかを確認する

        $ vagrant ssh-config
        Host default
          HostName 127.0.0.1
          User vagrant
          Port 2222
          UserKnownHostsFile /dev/null
          StrictHostKeyChecking no
          PasswordAuthentication no
          IdentityFile /Users/wang/.vagrant.d/insecure_private_key
          IdentitiesOnly yes
          LogLevel FATAL

----

node1に入ってchef-clientをインストール済みことを確認する

        $ chef-client -v
        Chef: 11.16.0
        
        $ cd /etc/chef && cat client.rb
        /etc/chef$ cat client.rb
        log_location     STDOUT
        chef_server_url  "https://api.opscode.com/organizations/tera"
        validation_client_name "tera-validator"
        node_name "node1"




        
