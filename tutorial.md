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



----

nodeのhostnameという属性を取得するそして、ウェブページに反映する
cookbooks/apache/templates/default/index.html.erlファイルに下の
内容を追加

        <p> My name is <%= node['hostname'] %> </p>


----

更新されたapacheクックブックをアップロードする

        $ knife cookbook upload apache

node1にログインして、chef-clientを実行する.  

        $ vagrant ssh
        $ sudo chef-client

注意：
> このhostnameがどこから来ているかというとohaiから来ている。
> ohaiはシステムの大量の情報を集めている。
> node1に$ ohai | grep hostname コマンドを実行したら, ウェブページ
> に反映しているhostnameと一致していることが分かる。
> 直接 $ ohai hostname を実行してもいい


----

knifeコマンドでnode1に関する基本情報を表示させることができる
下のコマンドはローカルのvagrantバーチャルマシンの情報を表示させている。

        $ knife node show node1
        Node Name:   node1
        Environment: _default
        FQDN:        vagrant-ubuntu-trusty-64
        IP:          10.0.2.15
        Run List:    recipe[apache]
        Roles:
        Recipes:     apache, apache::default
        Platform:    ubuntu 14.04
        Tags:

注意：
> node1のhostnameををチェックするもう一つの方法は下のコマンドを使用すること。
> '-a'はattributeのこと

        $ knife node show node1 -a hostname
        node1:
          hostname: vagrant-ubuntu-trusty-64

----

node1がたくさんの属性(attribute)があって、それ以外に自分で定義することもできる  
cookbooks/apache/attributes/の下にdefautl.rbファイルを作成して、追加属性を定義する

        default['apache']['greeting'] = "my friend"

上の属性をウェブページに反映するにはcookbooks/apache/templates/default/index.html.erb  
に下の一行を追加

        <h1>Hello, <%= node['apache']['greeting'] %> </h1>

node1にログインして、chef-clientを実行する。これで'Hello, my friend'というメッセージが  
ウェブページに反映されるはず

        $ vagrant ssh
        $ sudo chef-client

注意：
> 今追加したnode1に関するattributeをknifeでチェックするには下のコマンドを使う

        $ knife node show node1 -a apache
        node1:
          apache:
            greeting: my friend


----

これからroleに関して、みていく。簡単にいえば、このnodeをWebサーバーとして
みているか、DBサーバーとしてみているか、モニタリングサーバーとしてみているかのこと。  
roles/の下にwebserver.jsonファイルを作成  
roleごとに名前が必要、下の内容を記入  

        {
            "name" : "webserver",
            "default_attributes" : {
                "apache" : {
                    "greeting" : "Webinar"
                }
            },
            "run_list" : [
                "recipe[apache]"
            ]
        }

今の作ったroleをChefサーバーにアップロードする  

        $ knife role from file webserver.json

そして今からnode1のrun_listを修正したい。node1のrun_list  
というのはChef サーバー保存されているnode1に関するrun_listの情報

        $ knife node show node1
        Node Name:   node1
        Environment: _default
        FQDN:        vagrant-ubuntu-trusty-64
        IP:          10.0.2.15
        Run List:    recipe[apache]
        Roles:
        Recipes:     apache, apache::default
        Platform:    ubuntu 14.04
        Tags:

Run Listの中のrecipe[apache]を削除して、その代わりにさっき作った  
roleを指定したい。さっきの作ったroleの中にrun_listが書かれているので  
問題ない  

        $ knife node run list remove node1 "recipe[apache]"
        node1:
          run_list:
        $ knife node run list add node1 "role[webserver]"
        node1:
          run_list: role[webserver]
上のコマンドはなにをしたかというとChef サーバーにあるnode1に関するrun_listの
元の'recipe[apache]'を削除して、新しく'role[webserver]'を追加した。  
node1にログインして、chef-clientを実行して、修正を反映する。

        $ vagrant ssh
        $ sudo chef-client
注意：
> RoleはAttributeより優先順位が高い  
> Attributeは複数の場所で設定可能  
> 特定の用途のため、roleを利用して、Attributeを設定するのはいい考え  
> Roles must have a name  
> Roles may have a description  
> Roles may have a run_list, just like a node  
> Roles may set node attributes like 'default_attributes' or 'override_attributes'  
