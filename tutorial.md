準備
======

github.comからchef-repoをダウンロードする

        $ git clone git://github.com/opscode/chef-repo.git

----

https://manage.opscode.comから二つのpemファイルをダウンロードしてから  
knife.rbファイルを生成する。chef-repo/.chefディレクトリに配置する  




----

WorkStation(クックブック作る作業場)にknifeコマンドがインストールされていることを確認する

        $ knife --version
        Chef: 11.14.6




----

リモートのChefサーバにあるクライアントリストを表示する

        $ knife client list



        tera-validator
----

knifeでbootstrapを実行する。bootstrapの目的はnodeにchef-clientをインストールして、  
リモートのChef サーバーにnode1という名前でこのnodeを登録する。  

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


----

chef-repoディレクトリ下にapacheという名前のクックブックを作成する  
cookbooksディレクトリの下にapacheディレクトリができるはず

        $ knife cookbook create apache


----

cookbooks/apache/recipes/default.rbに記入する  

        package "apache2" do
            action :install
        end

注意:  
> Resources are declarative - that means 
> we say what we want to have happen, 
> rather than how
>
> Resources take action through Providers - providers 
> perform the how Chef use s the **platform** the node 
> is running to dertermine the correct provider for a resource


----

 cookbooks/apache/recipes/default.rbに二つ目のresourceを記入する  

        service "apache2" do
            action [:enable, :start]
        end
注意：  
> Resources are executed in order


----

cookbooks/apache/recipes/default.rbに三つ目のresourceを記入する  

        template "var/www/html/index.html" do
            source "index.html.erb"
            mode "0644"
        end


----

templates/default/下にindex.html.erbファイルを作成する  
簡単なhtmlコードを記入する  

        <h1>Hello, world</h1>


----

chef-repo ディレクトリからローカルのapacheクックブックをChefサーバーにアップロードする

        $ knife cookbook upload apache
        Uploading apache         [0.1.0]
        Uploaded 1 cookbook.

注意：  
>Chefサーバーのクックブックを削除する.'0.2.0'はクックブックのバージョンを指定する

        $ knife cookbook delete apache 0.2.0
        Do you really want to delete apache version 0.2.0? (Y/N)y
        Deleted cookbook[apache version 0.2.0]


----

node1に対して、run_listに実行してほしいrecipeを指定する。

        $ knife node run_list add node1 "recipe[apache]"
        node1:
          run_list: recipe[apache]

注意：
> The Run List is the ordered set of recipes and roles that the 
> Chef Client will execute on a node
> Recipes are specified by "recipe[name]"



----

node1にログインして、chef-clientを実行する.  
実行するのはapacheという名前のrecipe

        $ vagrant ssh
        $ sudo chef-client

注意：
> これで、ブラウザーを立ち上げて、node1のIPアドレスを入れたら、
> 'Hello, world'というメッセージだけのウェブページが表示されるはず


